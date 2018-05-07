package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

type server struct {
	startTime time.Time
}

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>Hello! This is the starter app!</body></html>")
}

func (s *server) healthz(w http.ResponseWriter, r *http.Request) {
	elapsed := time.Now().Sub(s.startTime)

	fmt.Fprintf(w, "<html><body>service up time:%v</body></html>", elapsed)
}

func main() {
	s := server{startTime: time.Now()}

	http.HandleFunc("/hello", hello)
	http.HandleFunc("/healthz", s.healthz)

	fmt.Printf("Listening on http://127.0.0.1:9090/\n")
	err := http.ListenAndServe(":9090", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
