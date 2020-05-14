package util

import (
	"crypto/md5"
	"encoding/hex"
	"strings"
)

func Md5Encode(data string) string {
	h := md5.New()
	h.Write([]byte(data))
	sum := h.Sum(nil)
	return hex.EncodeToString(sum)
}
func MD5Encode(data string) string {
	return strings.ToUpper(Md5Encode(data))
}
func MakePassword(password, salt string) string {
	return MD5Encode(password + salt)
}
func ValidatePassword(plainPassword, salt string, encodePassword string) bool {
	return MakePassword(plainPassword, salt) == encodePassword
}
