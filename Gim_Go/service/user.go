package service

import (
	"Gim_go/model"
	"Gim_go/util"
	"errors"
	"fmt"
	"log"
	"math/rand"
	"strconv"
	"time"
)

type Service struct {
}

//登录
func (s *Service) Login(mobile, password string) (*model.User, error) {
	tmp := model.User{}
	//查询用户数据
	_, err := DbEngine.Where("mobile=?", mobile).Cols("id", "nick_name", "token", "salt", "password", "mobile","avatar").Get(&tmp)
	if err != nil {
		return nil, err
	}
	if tmp.Id < 0 {
		return nil, errors.New("用户不存在")
	}

	//检验密码
	isSuccess := util.ValidatePassword(password, tmp.Salt, tmp.Password)
	if !isSuccess {
		return nil, errors.New("用户密码错误")
	}
	tmp.Token = util.Md5Encode(fmt.Sprintf("%06d", rand.Uint64()) + mobile + tmp.Salt)
	//上线
	tmp.Online = 1
	_, err = DbEngine.Where("id=?", tmp.Id).Update(&tmp)
	if err != nil {
		return nil, err
	}
	//更新token(没登录一次 就跟新一次token)
	//清空密码
	tmp.Password = ""
	tmp.Salt = ""
	return &tmp, nil
}

//注册
func (s *Service) Register(mobile, password, avatar, sex, nickName, desc string) (*model.User, error) {

	user := model.User{}
	//检测手机号是否存在了
	_, err := DbEngine.Where("mobile=?", mobile).Get(&user)
	if err != nil {
		log.Fatal(err)
		return nil, errors.New(err.Error())
	}
	//存在 则返回 该手机号已经注册的
	if user.Id > 0 {
		return nil, errors.New("手机号已经存在")
	} else {

		user.Mobile = mobile
		user.Avatar = avatar
		user.CreateTime = time.Now()
		user.Sex = sex
		user.Salt = fmt.Sprintf("%06d", rand.Uint32())
		user.Medo = desc
		user.NickName = nickName
		user.Password = util.MakePassword(password, user.Salt)
		user.Token = util.Md5Encode(fmt.Sprintf("%06d", rand.Uint64()) + mobile + user.Salt)
		_, err := DbEngine.InsertOne(&user)
		if err != nil {
			return nil, err
		}
		return &user, nil
	}

}
func (s *Service) UpdateUserInfo(mobile, password, avatar, sex, nickName, desc string) (*model.User, error) {

	user := model.User{}
	//检测手机号是否存在了
	_, err := DbEngine.Where("mobile=?", mobile).Get(&user)
	if err != nil {
		log.Fatal(err)
		return nil, errors.New(err.Error())
	}
	//存在 则返回 该手机号已经注册的
	if user.Id < 0 {
		return nil, errors.New("用户不存在")
	} else {

		if (mobile != "") {
			user.Mobile = mobile
		}
		if (avatar != "") {
			user.Avatar = avatar
		}
		if (sex != "") {
			user.Sex = sex
		}
		if (desc != "") {
			user.Medo = desc
		}
		if (nickName != "") {
			user.NickName = nickName;
		}
		_, err := DbEngine.Update(&user, &model.User{Id: user.Id})
		if err != nil {
			return nil, err
		}
		user.Password = ""
		user.Salt = ""
		return &user, nil
	}

}

func (s *Service) AddFriend(ownerId, destId int64) (bool, error) {
	ownerExit, err := existUser(ownerId)
	if !ownerExit || err != nil {
		return false, err
	}
	destExit, err := existUser(destId)
	if !destExit || err != nil {
		return false, err
	}
	session := DbEngine.NewSession()
	owenerContact := model.Contact{CreateTime: time.Now(), ContactType: model.CONTACT_SINGLE_CHAT, OwnerId: ownerId, DestId: destId}
	count, err := session.Where("owner_id=? and dest_id=?", ownerId, destId).Count(model.Contact{})
	if count == 0 {
		_, err = session.InsertOne(owenerContact)
	}
	if err != nil {
		//回滚
		err := session.Rollback()
		if err != nil {
			log.Println(err.Error())
		}
		return false, err
	}
	destContact := model.Contact{CreateTime: time.Now(), ContactType: model.CONTACT_SINGLE_CHAT, OwnerId: destId, DestId: ownerId}
	count, err = session.Where("owner_id=? and dest_id=?", destId, ownerId).Count(model.Contact{})
	if count == 0 {
		_, err = session.InsertOne(destContact)
	}

	if err != nil {
		//回滚
		err := session.Rollback()
		if err != nil {
			log.Println(err.Error())
		}
		return false, err
	}
	//提交
	err = session.Commit()
	if err != nil {
		return false, err
	}
	return true, nil
}
func existUser(id int64) (bool, error) {
	user := model.User{}
	//首先判断用户ownerId是存在
	//select count(*) from user where id=?
	count, err := DbEngine.Where("id=?", id).Count(user)
	if err != nil {
		return false, err
	}
	if count <= 0 {
		return false, errors.New("用户Id:" + strconv.Itoa(int(id)) + "不存在")
	} else {
		return true, nil
	}

}
func (s *Service) LoadFriend(ownerId int64) (*[]model.User, error) {
	users := make([]model.User, 0)

	rows, err := DbEngine.SQL("SELECT id,mobile,avatar,sex,nick_name,medo  FROM `user` a RIGHT JOIN (SELECT dest_id  FROM contact WHERE owner_id=?) b ON  a.id=b.dest_id;",
		ownerId).Rows(model.User{})
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		user := model.User{}
		err := rows.Scan(&user)
		if err != nil {
			log.Println(err.Error())
			continue
		}
		users = append(users, user)
	}

	return &users, nil

}
func (s *Service) RemoteFriend(ownerId int64, destId int64) (bool, error) {
	//delete from contact where (owner_id=3 and dest_id=4) or (owner_id=4 and dest_id=3)
	result, err := DbEngine.Exec("DELETE from contact where (owner_id=? and dest_id=?) or (owner_id=? and dest_id=?);", ownerId, destId, destId, ownerId)
	if err != nil {
		return false, err
	}
	affected, _ := result.RowsAffected()
	log.Println("remote friend :", affected)
	return true, nil
}
func (s *Service) IsAddNewFriend(token string) bool {
	user := model.User{}
	_, err := DbEngine.Where("token=?", token).Cols("is_add_new_friend").Get(&user)
	if err != nil {
		log.Println(err.Error())
		return false
	}
	if user.IsAddNewFriend == model.ADDNEWFRIEND {
		return true
	}
	return false
}
func (s *Service) UserInfo(ids []string) ([]model.User, error) {
	users := make([]model.User, 0)
	var sql = "SELECT id,mobile,avatar,sex,nick_name,medo  FROM `user` where id in "
	var args = "("
	for i, id := range ids {
		if i == len(ids)-1 {
			args = args + id + ")"
		} else {
			args = args + id + ","
		}
	}
	fmt.Println(sql + args)
	rows, err := DbEngine.SQL(sql + args).Rows(model.User{})
	if err != nil {
		return nil, err
	}
	log.Println(rows)
	for rows.Next() {
		user := model.User{}
		err := rows.Scan(&user)
		if err != nil {
			log.Println(err.Error())
			continue
		}
		log.Println(user)
		users = append(users, user)
	}
	return users, nil
}
func (s *Service) FindFriend(u string) ([]model.User, error) {
	reslut, e := DbEngine.SQL("SELECT id,mobile,avatar,sex,nick_name,medo FROM `user` WHERE mobile LIKE ? OR nick_name LIKE ? ;", u+"%", u+"%").Rows(model.User{})
	if e != nil {
		return nil, e
	}
	var users = make([]model.User, 0);
	for reslut.Next() {
		var user = model.User{};
		e := reslut.Scan(&user)
		if e != nil {
			log.Println(e.Error())
			continue
		}
		users = append(users, user)
	}
	return users, nil

}
