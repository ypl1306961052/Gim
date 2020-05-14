package model

import "time"

const (
	USER_MAN    = "M"
	USER_FALMAN = "F"
	USER_UNKONM = "U"
)
const (
	ADDNEWFRIEND=1;
	NOTADDNEWFRIEND=0;
)
type User struct {
	//用户ID
	Id int64 `form:"id",json:"id,omitempty",xorm:"pk autoincr bigint(20)"`
	//用户手机
	Mobile string `form:"mobile",json:"mobile,omitempty",xorm:"varchar(20)"`
	//用户的密码
	Password string `form:"password",json:"password,omitempty",xorm:"varchar(40)"`
	//用户头像的url
	Avatar string `form:"avatar",json:"avatar,omitempty",xorm:"varchar(150)"`
	//性别
	Sex string `form:"sex",json:"sex,omitempty",xorm:"char(2)"`
	//userName
	NickName string `form:"nickname",json:"username,omitempty",xorm:"varchar(20)"`
	//盐
	Salt string `form:"salt",json:"salt,omitempty",xorm:"varchar(10)"`
	//是否在线
	Online int `form:"online",json:"online,omitempty",xorm:"int"`
	//token
	Token string `form:"token",json:"token,omitempty",xorm:"varchar(20)"`
	//medo 描述
	Medo string `form:"medo",json:"medo,omitempty",xorm:"varchar(140)"`
	//创建时间
	CreateTime time.Time `form:"create_time",json:"create_time,omitempty",xorm:"timestamp"`
	//是否添加新的好友 0没有添加 1有新增的好友
	IsAddNewFriend int `from:"is_add_new_friend",json:"is_add_new_friend,omitempty",xorm:"TINYINT DEFAULT 0"`
}
