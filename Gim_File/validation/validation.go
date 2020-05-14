package validation

import (
	"Gim_File/dao"
	"log"
)

type Validation interface {
	ValidationToken(token string) bool
}
type SqlValidation struct {
}

//以后分布式的校验
//目前直接在mysql中查询数据
func (s *SqlValidation) ValidationToken(token string) bool {
	resultsSlice, err := dao.DbEngine.Query("select token from user where token=?", token)
	if err != nil {
		log.Println(err.Error())
		return false
	} else {
		if resultsSlice != nil && len(resultsSlice) > 0 {
			return true
		} else {
			return false
		}
	}
}
