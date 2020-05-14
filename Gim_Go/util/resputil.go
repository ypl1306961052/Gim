package util

import (
	"Gim_go/model"
	"encoding/json"
	"log"
	"net/http"
)

func Resp(w *http.ResponseWriter, code int, data interface{}, msg string) {
	(*w).Header().Set("Content-Type", "application/json; charset=utf-8")

	respBody := model.RespBody{Code: code, Data: data, Msg: msg}

	respJson, err := json.Marshal(respBody)
	log.Print(string(respJson))
	if err != nil {
		(*w).Write([]byte(err.Error()))
	} else {

		(*w).Write(respJson)
	}

}
func RespOk(w *http.ResponseWriter, code int, data interface{}) {
	Resp(w, code, data, "")

}
func RespOkAndMsg(w *http.ResponseWriter, code int, data interface{}, msg string) {
	Resp(w, code, data, msg)
}
func RespFail(w *http.ResponseWriter, code int, msg string) {
	Resp(w, code, "", msg)
}
