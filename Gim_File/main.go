package main

import (
	"Gim_File/util"
	"Gim_File/validation"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"time"
)

var host = "192.168.0.111"
var port = "8081"
var whost="127.0.0.1"
var Validation = &validation.SqlValidation{}
var filePath = "/"

func main() {
	host = os.Args[1]
	port = os.Args[2]
	whost=os.Args[3]
	dir := http.Dir("./file")
	http.Handle(filePath, http.FileServer(dir))
	http.HandleFunc("/file/upload", fileUpload)
	log.Println("文件服务" + host + ":" + port + "已经启动")
	log.Fatal(http.ListenAndServe(host+":"+port, nil))
}

type FileResponse struct {
	Time      int64  `json:"time"`
	Url       string `json:"url"`
	FileName  string `json:"name"`
	FileSize  int64  `json:"size"`
	IsSuccess bool   `json:"isSuccess"`
	Reason    string `json:"reason,omitempty"`
}

func fileUpload(w http.ResponseWriter, r *http.Request) {
	log.Println("文件上传")
	token := r.URL.Query().Get("token")
	if !Validation.ValidationToken(token) {
		util.RespFail(&w, -1, "token 无效")
		return
	}
	switch r.Method {
	case "POST":
		err := r.ParseMultipartForm(100000)
		if err != nil {
			util.RespFail(&w, -1, err.Error())
			return
		}
		m := r.MultipartForm
		file := m.File["file"]
		var responseData = make([]FileResponse, 0)
		responses := make(chan FileResponse, 2)
		defer close(responses)
		for k, v := range file {
			log.Println("-------------", k, "---------------------")
			log.Println("文件名字", v.Filename)
			log.Println("文件大小", v.Size)

			go saveFile(token, v, responses)

			log.Println("-------------", k, "---------------------")
		}
		var i = 0
		if file != nil {
			for {
				select {
				case data := <-responses:
					responseData = append(responseData, data)
					i++
					if i == len(file) {
						util.RespOk(&w, 0, responseData)
						return
					}
				}
			}
		} else {
			log.Println("文件删除失败,数据为空")
			util.RespFail(&w, -1, "数据为空")
			return
		}

	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
		util.RespFail(&w, -1, "请求的方法不对")
	}

}
func saveFile(token string, header *multipart.FileHeader, responses chan FileResponse) {
	response := FileResponse{FileName: header.Filename, Time: time.Now().Unix(), FileSize: header.Size, IsSuccess: true}
	defer func() {
		//往里面添加值
		log.Println(header.Filename + "文件保存成功")
		responses <- response
	}()
	srcFile, err := header.Open()

	if err != nil {
		log.Println(err.Error())
		response.IsSuccess = false
		response.Reason = err.Error()
		return
	}
	defer srcFile.Close()

	b, err := PathExists("./file/" + token)
	if !b {
		err = os.Mkdir("./file/"+token, 0777)
	}
	if err != nil {
		response.IsSuccess = false
		response.Reason = err.Error()
		return
	}
	var path = token + "/" + header.Filename
	destFile, err := os.Create("./file/" + path)
	if err != nil {
		log.Println(err.Error())
		response.IsSuccess = false
		response.Reason = err.Error()
		return
	}
	defer destFile.Close()
	_, err = io.Copy(destFile, srcFile)
	if err != nil {
		log.Println(err.Error())
		response.IsSuccess = false
		response.Reason = err.Error()
		return
	}
	response.IsSuccess = true
	response.Url = createFileUrl(whost, port, filePath, path)
}
func createFileUrl(host string, port string, filePath string, file string) string {
	return "http://" + host + ":" + port + filePath + file
}
func PathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}
