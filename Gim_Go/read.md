1:登录接口
2:注册接口



3:获取好友接口
4:添加好友接口
message{
ownerId,自己的Id
destId,好友Id
type,类型 单聊 还是 群聊
creat_time:创建时间


}
5:删除好友接口


群聊


单聊


SET CGO_ENABLED=0 SET GOOS=linux SET GOARCH=amd64 go build main.go
