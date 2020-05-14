package ctrl

import (
	"Gim_go/auth"
	"Gim_go/service"
	"Gim_go/util"
	"net/http"
	"strconv"
)

var dbAuth auth.UserAuth

func init() {
	engine := service.DbEngine
	if engine == nil {
		service.InitDb()
	}
	dbAuth = &auth.UserDbAuth{Db: engine}
}
func Auth(h http.HandlerFunc) http.HandlerFunc {
	return func(writer http.ResponseWriter, request *http.Request) {
		//先从url
		//再从head
		//最后body
		token := request.URL.Query().Get("token")
		idStr := request.URL.Query().Get("id")
		id, err := strconv.ParseInt(idStr, 10, 64)
		if err != nil {
			util.RespFail(&writer, -1, "id error")
			return
		}

		if token == "" {
			token = request.Header.Get("token")
		}
		if token == "" {
			err := request.ParseForm()
			if err != nil {
				util.RespFail(&writer, -1, err.Error())
				return
			}
			token = request.PostForm.Get("token")
		}
		if token == "" {
			util.RespFail(&writer, -1, "token 为空")
			return
		}

		authBool := dbAuth.Auth(id, token)
		if authBool {
			request.Header.Set("check", "true")
			h(writer, request)
		} else {
			util.RespFail(&writer, -100, "token 无效")
			return
		}

	}
}
