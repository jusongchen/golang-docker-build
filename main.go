package main

import (
	"fmt"
	"log"
	"net/http"
)

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>Hello! This is the starter app for the Ursa project. </body></html>")
}

func main() {
	http.HandleFunc("/", hello)
	fmt.Printf("Listening on http://127.0.0.1:9090/\n")
	err := http.ListenAndServe(":9090", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
