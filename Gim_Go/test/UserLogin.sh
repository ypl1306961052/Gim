#curl "http://127.0.0.1:8080/user/login" -X POST -d "mobile=15708989110&password=123456"
#curl "http://127.0.0.1:8080/user/register" -X POST -d "mobile=15708989112&password=123456&sex=M&username=ypl"
curl "http://127.0.0.1:8080/user/addFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3&destId=5"
curl "http://127.0.0.1:8080/user/addFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3&destId=4"
#curTime=
#for i in {1..100} ; do
#    curl "http://127.0.0.1:8080/user/addFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3&destId=4" >> ./log.txt
#done
#echo ``
curl "http://127.0.0.1:8080/user/loadFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3"

echo "删除好友 3 and 5"

curl "http://127.0.0.1:8080/user/remoteFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3&destId=5"
curl "http://127.0.0.1:8080/user/loadFriend?token=c79e0c2e12e192ed24b86d0ece89fe77" -X POST -d "ownerId=3"

# shellcheck disable=SC2034
# http://127.0.0.1:8080/view/chat.html?id=5&receiveId=3&token=d5d0c23950a2b119e45b2fd1631a264c
# http://127.0.0.1:8080/view/chat.html?id=3&receiveId=5&token=c79e0c2e12e192ed24b86d0ece89fe77

curl "http://192.168.0.111:8080/user/info" -X POST -d "userIds=1,2,3"