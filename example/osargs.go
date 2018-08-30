package main

import "C"

import (
	"fmt"
	"os"
)

//export print_args
func print_args() {
	fmt.Println(os.Args)
}

func main() {}
