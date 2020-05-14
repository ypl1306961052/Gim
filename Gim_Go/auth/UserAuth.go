package auth

import (
	"Gim_go/model"
	"github.com/go-xorm/xorm"
	"log"
)

type UserAuth interface {
	Auth(id int64, token string) bool
}

type UserDbAuth struct {
	Db *xorm.Engine
}

//使用数据库验证 后期可以使用redis缓存进行判断
func (u *UserDbAuth) Auth(id int64, token string) bool {
	user := model.User{Id: id}
	_, err := u.Db.Get(&user)
	if err != nil {
		log.Println(err)
		return false
	}
	return user.Token == token
}
