package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"time"
)

var wg sync.WaitGroup

func main() {

	if len(os.Args) < 2 {
		fmt.Println("please provide the URL of the service")
		return
	}
	url := os.Args[1]

	if url == "" {
		fmt.Println("no URL set")
		return
	}

	var numberOfThreads int
	numberOfThreads = 1
	if len(os.Args) >= 3 {
		numberOfThreadsInt64, err := strconv.ParseInt(os.Args[2], 10, 64)
		if err != nil {
			numberOfThreads = 1
		} else {
			numberOfThreads = int(numberOfThreadsInt64)
		}
	}

	fmt.Println("Exit program with CTRL+C")
	fmt.Println()

	tr := &http.Transport{
		DialContext: resolveXipIoWithContext,
	}
	c := &http.Client{Timeout: 3 * time.Second, Transport: tr}

	wg.Add(numberOfThreads)
	for i := 0; i < numberOfThreads; i++ {
		go doRequests(url, c)
		fmt.Println("Created new Thread")
	}
	wg.Wait()

}

func doRequests(url string, c *http.Client) {
	defer wg.Done()
	for true {
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			log.Fatalln(err)
		}
		req.Header.Set("X-Custom-Header", "myvalue")
		req.Header.Set("Content-Type", "application/json")

		resp, err := c.Do(req)

		if err != nil {
			continue
		}

		if resp.StatusCode == 200 {
			log.Println("Request finished")
		}
		resp.Body.Close()
	}
}

// resolveXipIo resolves a xip io address
func resolveXipIoWithContext(ctx context.Context, network, addr string) (net.Conn, error) {
	dialer := &net.Dialer{
		DualStack: true,
	}

	if strings.Contains(addr, ".xip.io") {

		regex := `\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?).xip.io\b`
		re := regexp.MustCompile(regex)
		ipWithXipIo := re.FindString(addr)
		ip := ipWithXipIo[:len(ipWithXipIo)-len(".xip.io")]

		regex = `:\d+$`
		re = regexp.MustCompile(regex)
		port := re.FindString(addr)

		var newAddr string
		if port != "" {
			newAddr = ip + port
		}
		addr = newAddr
	}
	return dialer.DialContext(ctx, network, addr)
}
