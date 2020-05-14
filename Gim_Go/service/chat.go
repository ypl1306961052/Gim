package service

import (
	"Gim_go/model"
	"encoding/json"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"strconv"
	"sync"
)

var rwLock sync.RWMutex
var clientMap map[int64]*Node = make(map[int64]*Node, 1024)

type Node struct {
	Con       *websocket.Conn
	DateQueue chan []byte
}

///chat?id=1&token=23qweqwrqwe
func (s *Service) Chat(w http.ResponseWriter, r *http.Request) {
	useIdStr := r.URL.Query().Get("id")
	useId, err := strconv.ParseInt(useIdStr, 10, 64)
	if err != nil {
		log.Println(err.Error())
		return
	}
	connect, err := (&websocket.Upgrader{CheckOrigin: func(r *http.Request) bool {
		return "true" == r.Header.Get("check")
	}}).Upgrade(w, r, nil)
	if err != nil {
		log.Println(err.Error())
		return
	}
	node := &Node{Con: connect, DateQueue: make(chan []byte, 50)}
	rwLock.Lock()
	//如果之前存在了解者需要把之前的链接去除掉
	lastNode := clientMap[useId]
	if lastNode != nil {
		log.Println(useId, "关闭之前的链接")
		err := lastNode.Con.Close()
		if err != nil {
			log.Println(err.Error())
			log.Println(useId, "关闭之前的链接失败")
		}
		close(lastNode.DateQueue)
		log.Println(useId, "关闭之前的链接成功")
	}
	clientMap[useId] = node
	log.Println(useId, "创建链接成功")
	rwLock.Unlock()
	go sendproc(node)
	go receiveproc(node)
}

//发送协程
func sendproc(node *Node) {
	for {
		select {
		case data := <-node.DateQueue:
			err := node.Con.WriteMessage(websocket.TextMessage, data)
			if err != nil {
				log.Println(err.Error())
				return
			}

		}

	}

}

//接受消息
func receiveproc(node *Node) {
	for {
		_, p, err := node.Con.ReadMessage()
		if err != nil {
			log.Println(err.Error())
			return
		}
		message := model.ChatMessage{}
		log.Println("rec:", string(p))
		err = json.Unmarshal(p, &message)
		log.Println("rec:", message)
		if err != nil {
			log.Println(err.Error())
		} else {
			//分发数据
			dispense(message)
		}

	}

}
func dispense(message model.ChatMessage) {

	receiveId := message.ReceiveId
	messageJson, err := json.Marshal(message)
	if err != nil {
		log.Println(err.Error())
		return
	}
	if receiveId != message.SendId {
		sendMessage(receiveId, string(messageJson))
	}
}
func sendMessage(useId int64, message string) {
	rwLock.RLock()
	node, ok := clientMap[useId]
	rwLock.RUnlock()
	if ok {
		node.DateQueue <- []byte(message)
	} else {
		//用户不在线
		//怎么处理
		//todo
		log.Println(useId, "用户不在线")
	}
}
