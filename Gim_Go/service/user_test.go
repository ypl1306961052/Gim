package service

import (
	"Gim_go/model"
	"fmt"
	"testing"
)

func TestService_LoadFriend(t *testing.T) {
	type args struct {
		ownerId int64
	}
	tests := []struct {
		name    string
		args    args
		want    []model.User
		wantErr bool
	}{
		// TODO: Add test cases.
		{name:"loadFriend1",args:args{ownerId:3},want:nil,wantErr:false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			s := &Service{}
			got, err := s.LoadFriend(tt.args.ownerId)
			if (err != nil) != tt.wantErr {
				t.Errorf("LoadFriend() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			fmt.Println(got)
			//if !reflect.DeepEqual(got, tt.want) {
			//	t.Errorf("LoadFriend() got = %v, want %v", got, tt.want)
			//}
		})
	}
}