package model

const (
	MESSAGE_SINGlE    = 1
	MESSAGE_GROUP     = 2
	MESSAGE_HEARTBEAT = 3
)
const (
	//文字
	CONTENT_TEXT = 1
	//图片
	CONTENT_IMAGE = 2
	//语音
	CONTENT_VOICE = 3
)

type ChatMessage struct {
	Id        int64 `json:"id"`
	//时间戳
	Time uint64 	`json:"time"`
	SendId    int64 `json:"sendId"`
	ReceiveId int64 `json:"receiveId"`
	//单聊 还是群聊 还是 心跳
	Cmd int `json:"cmd"`
	// 聊天类型
	Media int `json:"media"`
	//聊天内容
	Content string `json:"content"`
	//url 图片的url
	Url string `json:"url"`
	//语音的长度
	VoiceLen float64 `json:"voiceLen"`
}
