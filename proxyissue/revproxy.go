package main
 
import (
        "crypto/tls"
        "fmt"
        "golang.org/x/net/http2"
        "log"
        "net/http"
        "net/http/httputil"
        "net/url"
)

func main() {
        u, err := url.Parse("https://127.0.0.2:50051")
        u.Scheme = "https"
        if err != nil {
                log.Fatal(err)
        }
        transport := &http2.Transport{
                TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		//DisableCompression: true,
        }
        p := httputil.NewSingleHostReverseProxy(u)
        p.Transport = transport
	fmt.Printf("Proxy serving at :9009\n")
        log.Fatal(http.ListenAndServeTLS(":9009", "tls.crt", "tls.key", p))
}
