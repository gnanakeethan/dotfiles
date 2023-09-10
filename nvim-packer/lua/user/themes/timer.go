package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
	
	"github.com/nathan-osman/go-sunrise"
)

func main() {
	// get latitude and longitiude from runtime arguments
	lat, _ := strconv.ParseFloat(os.Args[1], 64)
	lng, _ := strconv.ParseFloat(os.Args[2], 64)
	sunrise, sunset := sunrise.SunriseSunset(
		lat, lng, // Toronto, CA
		time.Now().Year(), time.Now().Month(), time.Now().Day(),
	)
	if os.Args[3] == "sunrise" {
		fmt.Println(sunrise.Unix())
	} else {
		fmt.Println(sunset.Unix())
	}
}
