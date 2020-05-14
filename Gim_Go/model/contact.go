package model

import "time"

const (
	CONTACT_SINGLE_CHAT = 1
	CONTACT_GROUP_CHAT  = 2
)

type Contact struct {
	//自己ID
	OwnerId int64 `form:"ownerId",json:"ownerId,omitempty",xorm:" bigint(20)"`
	//好友ID
	DestId int64 `form:"destId",json:"destId,omitempty",xorm:"bigint(20)"`

	ContactType int `form:"type",json:"type,omitempty",xorm:"int"`
	//todo 添加 索引
	CreateTime time.Time  `form:"createTime",json:"createTime,omitempty",xorm:"timestamp"`
}
