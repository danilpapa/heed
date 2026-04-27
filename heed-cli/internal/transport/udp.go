package transport

import (
	"encoding/json"
	"heed-cli/internal/model"
	"net"
)

type UDPListener struct {
	conn *net.UDPConn
}

func NewUDPListener(port string) (*UDPListener, error) {
	addr, err := net.ResolveUDPAddr("udp", ":" + port)
	if err != nil {
		return nil, err
	}
	
	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		return nil, err
	}
	
	return &UDPListener{conn: conn}, nil
}

func (l *UDPListener) Read() (*model.Event, error) {
	buf := make([]byte, 65535)
	
	n, _, err := l.conn.ReadFromUDP(buf)
	if err != nil {
		return nil, err
	}
	var buffSlice []byte = buf[:n]
	var model model.Event
	
	if err :=json.Unmarshal(buffSlice, &model); err != nil {
		return nil, err
	}
	
	return &model, nil
}