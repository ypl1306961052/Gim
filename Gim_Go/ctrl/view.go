package ctrl

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
)

func View() {
	glob, err := template.ParseGlob("./view/**/*")
	if err != nil {
		log.Println(err.Error())
		return
	}
	for _, v := range glob.Templates() {
		name := v.Name()
		http.HandleFunc(name, func(writer http.ResponseWriter, request *http.Request) {

			err = glob.ExecuteTemplate(writer, name, nil)
			if err != nil {
				log.Println(err.Error())
			}
		})

	}

}

type data struct {
	SendId    int64
	ReceiveId int64
	Token     string
}

func ChatView(w http.ResponseWriter, r *http.Request) {
	tpl, err := template.ParseFiles("./view/chat.html")
	if err != nil {
		log.Println(err.Error())
	}
	sendIdStr := r.URL.Query().Get("id")
	receiveIdStr := r.URL.Query().Get("receiveId")
	sendId, err := strconv.ParseInt(sendIdStr, 10, 64)
	if err != nil {
		log.Println(err.Error())
		return
	}

	receiveId, err := strconv.ParseInt(receiveIdStr, 10, 64)
	if err != nil {
		log.Println(err.Error())
		return
	}
	token := r.URL.Query().Get("token")
	d := data{SendId: sendId, ReceiveId: receiveId, Token: token}

	tpl.ExecuteTemplate(w, "login", &d)
}
