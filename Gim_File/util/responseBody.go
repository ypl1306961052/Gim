package util

type RespBody struct {
	Code int    `json:"code"`
	Data interface{} `json:"data,omitempty"`
	Msg  string `json:"msg,omitempty"`
}
