package main

import (
	"Gim_go/ctrl"
	_ "github.com/go-sql-driver/mysql"
	"log"
	"net/http"
	"os"
)

func main() {
	var host = os.Args[1];
	var port = os.Args[2];
	http.HandleFunc("/user/login", ctrl.Login)
	http.HandleFunc("/user/register", ctrl.Register)
	http.HandleFunc("/user/info", ctrl.UserInfo)
	http.HandleFunc("/user/update", ctrl.UpdateUserInfo)
	http.HandleFunc("/user/addFriend", ctrl.Auth(ctrl.AddFriend))
	http.HandleFunc("/user/findFriend", ctrl.Auth(ctrl.FindFriend))
	http.HandleFunc("/user/loadFriend", ctrl.Auth(ctrl.LoadFriend))
	http.HandleFunc("/user/remoteFriend", ctrl.Auth(ctrl.RemoteFriend))
	http.HandleFunc("/user/isAddNewFriend", ctrl.Auth(ctrl.IsAddNewFriend))
	http.HandleFunc("/user/chat", ctrl.Auth(ctrl.Chat))
	http.Handle("/asset/", http.FileServer(http.Dir("./asset")))
	http.HandleFunc("/view/chat.html", ctrl.Auth(ctrl.ChatView))

	log.Println("chat start service ,port " + host + ":" + port)
	err := http.ListenAndServe(host+":"+port, nil)
	if err != nil {
		log.Fatal(err.Error())
	}
}
