package ctrl

import (
	"Gim_go/service"
	"Gim_go/util"
	"log"
	"net/http"
	"strconv"
	"strings"
)

var UserService *service.Service

func init() {
	UserService = new(service.Service)
}
func Login(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		log.Fatal(err)

	}
	mobile := r.PostForm.Get("mobile")
	password := r.PostForm.Get("password")
	user, err := UserService.Login(mobile, password)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
	} else {
		util.RespOkAndMsg(&w, 0, user, "登录成功")
	}

}
func Register(w http.ResponseWriter, r *http.Request) {

	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		log.Fatal(err)

	}
	mobile := r.PostForm.Get("mobile")
	password := r.PostForm.Get("password")
	log.Println(password)
	if len(password) < 6 {
		util.RespFail(&w, -1, "密码设置的太短了,密码为6～12位")
		return
	}
	avatar := r.PostForm.Get("avatar")
	sex := r.PostForm.Get("sex")
	userName := r.PostForm.Get("username")
	desc := r.PostForm.Get("desc")
	registerUser, err := UserService.Register(mobile, password, avatar, sex, userName, desc)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	} else {
		util.RespOk(&w, 0, registerUser)
	}

}
func UpdateUserInfo(w http.ResponseWriter, r *http.Request) {

	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		log.Fatal(err)

	}
	mobile := r.PostForm.Get("mobile")
	//password := r.PostForm.Get("password")
	//log.Println(password)
	//if len(password) < 6 {
	//	util.RespFail(&w, -1, "密码设置的太短了,密码为6～12位")
	//	return
	//}
	avatar := r.PostForm.Get("avatar")
	sex := r.PostForm.Get("sex")
	userName := r.PostForm.Get("username")
	desc := r.PostForm.Get("desc")
	registerUser, err := UserService.UpdateUserInfo(mobile, "", avatar, sex, userName, desc)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	} else {
		util.RespOk(&w, 0, registerUser)
	}

}

func AddFriend(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}

	ownerIdStr := r.PostForm.Get("ownerId")
	destIdStr := r.PostForm.Get("destId")
	ownerId, err := strconv.ParseInt(ownerIdStr, 10, 64)
	if err != nil {
		util.RespFail(&w, -1, "ownerId parse error,error:"+err.Error())
		return
	}
	destId, err := strconv.ParseInt(destIdStr, 10, 64)
	if err != nil {
		util.RespFail(&w, -1, "ownerId parse error,error:"+err.Error())
		return
	}

	addFiendBool, err := UserService.AddFriend(ownerId, destId)
	if addFiendBool && err == nil {
		util.RespOkAndMsg(&w, 0, nil, "添加好友成功")
		return
	} else {
		util.RespFail(&w, -1, err.Error())
		return
	}
}
func LoadFriend(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}
	ownerIdStr := r.URL.Query().Get("ownerId")
	if ownerIdStr == "" {
		ownerIdStr = r.PostForm.Get("ownerId")
	}
	if ownerIdStr == "" {
		util.RespFail(&w, -1, "ownerId is empty")
		return
	}
	ownerId, err := strconv.ParseInt(ownerIdStr, 10, 64)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}
	users, err := UserService.LoadFriend(ownerId)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}
	util.RespOk(&w, 1, users)
	return
}
func RemoteFriend(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}

	ownerIdStr := r.PostForm.Get("ownerId")
	destIdStr := r.PostForm.Get("destId")
	ownerId, err := strconv.ParseInt(ownerIdStr, 10, 64)
	if err != nil {
		util.RespFail(&w, -1, "ownerId parse error,error:"+err.Error())
		return
	}
	destId, err := strconv.ParseInt(destIdStr, 10, 64)
	if err != nil {
		util.RespFail(&w, -1, "ownerId parse error,error:"+err.Error())
		return
	}
	ok, err := UserService.RemoteFriend(ownerId, destId)
	if ok {
		util.RespOkAndMsg(&w, 0, nil, "删除好友成功")
		return
	} else {
		util.RespFail(&w, -1, err.Error())
		return
	}
}
func IsAddNewFriend(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if UserService.IsAddNewFriend(token) {
		util.RespOkAndMsg(&w, 0, nil, "有新增的好友")
	} else {
		util.RespOkAndMsg(&w, -1, nil, "没有新增的好友")
	}

}
func Chat(w http.ResponseWriter, r *http.Request) {
	UserService.Chat(w, r)
}
func UserInfo(w http.ResponseWriter, r *http.Request) {
	err := r.ParseForm()
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	}
	userIds := r.PostForm.Get("userIds")
	if userIds == "" {
		util.RespFail(&w, -1, "请传入参数userIds")
		return
	}
	users := strings.Split(userIds, ",")
	info, err := UserService.UserInfo(users)
	if err != nil {
		util.RespFail(&w, -1, err.Error())
		return
	} else {
		util.RespOk(&w, 1, info)
	}

}
func FindFriend(w http.ResponseWriter, r *http.Request) {
	var u = r.URL.Query().Get("u")
	users, e := UserService.FindFriend(u)
	if (e != nil) {
		util.RespFail(&w, -1, e.Error());
		return
	}
	util.RespOk(&w, 0, users);
	return
}
