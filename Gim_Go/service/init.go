package service

import (
	"Gim_go/model"
	"errors"
	_ "github.com/go-sql-driver/mysql"
	"github.com/go-xorm/xorm"
	"log"
	"sync"
)

var DbEngine *xorm.Engine
var wg sync.Once

func init() {

	InitDb()
}
func InitDb() {
	wg.Do(func() {
		driveName := "mysql"
		DsName := "root:YPL123456ypl@(127.0.0.1:3306)/go_chat?charset=utf8"
		var err = errors.New("")
		DbEngine, err = xorm.NewEngine(driveName, DsName)
		if DbEngine == nil {
			log.Fatal("db init error error:", err.Error())
			return
		}
		err = DbEngine.Ping()
		if err != nil {
			log.Fatal(err)
		}
		DbEngine.ShowSQL(true)
		DbEngine.SetMaxOpenConns(20)

		err = DbEngine.Sync2(new(model.User))
		if err != nil {
			log.Fatal(err)
		}
		err = DbEngine.Sync2(new(model.Contact))
		if err != nil {
			log.Fatal(err)
		}
		log.Println("base db init ok")
	})

}
