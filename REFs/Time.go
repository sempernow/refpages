package main

import (
	"crypto/sha1"
	"encoding/binary"
	"fmt"
	"io"
	"reflect"
	"runtime"
	"strconv"
	"time"
	"unsafe"
)

// time Constants
// https://golang.org/pkg/time/#pkg-constants

func main() {

	// Day, Month, Year, ...
	// https://yourbasic.org/golang/day-month-year-from-time/
	year, month, day := time.Now().Date()
	fmt.Printf("year: %s, month: %s, day: %s\n",
		IntToString(year), month.String(), IntToString(day),
	)
	tt := time.Now()
	yr := tt.Year()  // type int
	mo := tt.Month() // type time.Month
	d := tt.Day()    // type int
	fmt.Printf("year: %s, month: %s, day: %s\n",
		IntToString(yr), mo.String(), IntToString(d),
	)

	// Local | Zulu :: time.Time
	fmt.Println(UnixToTimeLocal(1594562637)) // 2020-07-12 10:03:57 -0400 EDT
	fmt.Println(UnixToTimeUTC(1594562637))   // 2020-07-12 14:03:57 +0000 UTC
	fmt.Println(UnixSecToMsec(1594562637))   // 1594562637000

	// Local | Zulu :: string @ RFC3339
	fmt.Println(time.Now().Format(time.RFC3339))       // 2020-07-22T10:21:51-04:00
	fmt.Println(time.Now().UTC().Format(time.RFC3339)) // 2020-07-22T14:21:51Z

	// Local | Zulu :: string @ RFC3339 :: per utility functions
	x := time.Now()
	l := TimeStringLocal(x)
	z := TimeStringZulu(x)
	fmt.Println(l)                                     // 2020-07-22T10:21:51-04:00
	fmt.Println(z)                                     // 2020-07-22T14:21:51Z
	fmt.Println(TimeToUnixSec(x), "::", x)             // 1595428805
	fmt.Println(TimeToUnixSec(x.UTC()), "::", x.UTC()) // 1595428805

	// "2019-08-23 12:24:12.8403551 +0000 UTC"  UTC Time (time.Time)
	fmt.Printf("Now().UTC()  :: %v\n", time.Now().UTC())
	fmt.Printf("Now()  :: %v\n", time.Now())

	// "2017-05-11 08:29:16 -0400 DST"  Unix Timestamp (int64) to time.Time in UTC/DST
	fmt.Printf("Unix(1494505756, 0)  :: %v\n", time.Unix(1494505756, 0))

	// Unix Timestamp
	time.Now().UnixNano() // 1566562667852805700 (nanoseconds)
	fmt.Println(time.Now().UnixNano() / int64(time.Millisecond))
	// 1566562667852 (milliseconds)
	// 1594523726522
	time.Now().Unix()              // 1566562667 (seconds)
	time.Now().Format(time.RFC822) // 02 Jan 06 15:04 MST

	fmt.Println("=============", fmt.Sprintf("%v", time.Now().Unix()))
	// "11 May 17 08:29 -0400"  RFC822Z
	time.Unix(1494505756, 0).Format(time.RFC822Z)

	// "2017-05-11T08:29:16-04:00"
	time.Unix(1494505756, 0).Format(time.RFC3339)

	// "2017-05-11-[08.29.16]"  Custom format
	time.Unix(1494505756, 0).Format("2006-01-02-[15.04.05]")

	fmt.Printf("Age(time.Duration): %v\n", Age(time.Since(time.Now().Round(0).Add(-(26*3600+60+45)*time.Second))))
	fmt.Printf("Age(time.Duration): %v\n", Age(time.Since(time.Now().Round(0).Add(-(3300)*time.Second))))

	// Add time from now  https://stackoverflow.com/questions/40589353/adding-hours-minutes-seconds-to-current-time
	var hours, mins, sec int
	future := time.Now().Local().Add(time.Hour*time.Duration(hours) +
		time.Minute*time.Duration(mins) +
		time.Second*time.Duration(sec))
	// Simplified
	var h, m, s time.Duration
	future = time.Now().Add(time.Hour*h + time.Minute*m + time.Second*s)
	fmt.Println(future)

	// PostgreSQL is ISO8601  "2020-07-12 03:15:26.522447+00"
	// @ Golang does NOT have ISO8601 constant
	fmt.Printf("Now().Format(time.RFC822)  :: %v\n", time.Now().Format(time.RFC822))

	// HashSum of String === Postgres encode(digest(tt::text, 'sha1'), 'hex')
	tt := UnixMsecNow()
	tt = int64(1594523726522)
	hash := sha1.New()
	io.WriteString(hash, Int64ToString(tt))
	fmt.Printf("%x\n", hash.Sum(nil))
	fmt.Printf("%s\n", BytesToHex(hash.Sum(nil)))
	// HashSum of Bytes (SHA-1 Checksum)
	fmt.Printf("%x\n", sha1.Sum(Int64ToBytes(tt)))
	fmt.Printf("%s\n", CheckSumSHA1(Int64ToBytes(tt)))

	//s := "2020-07-12 03:15:26.522447+00"

}

func substr() string {
	// SUBSTRING | TRUNCATE
	runes := []rune(strconv.FormatInt(time.Now().UnixNano(), 10))
	// 1568133245729678300
	return string(runes[10:])
	// 729678300
}

// UnixToTimeLocal returns UTC Local w/ Offset
func UnixToTimeLocal(sec int64) time.Time {
	return time.Unix(sec, 0)
}

// UnixToTimeUTC returns UTC Zulu time (Zero Offset)
func UnixToTimeUTC(sec int64) time.Time {
	return time.Unix(sec, 0).UTC()
}

// TimeStringLocal :: `RFC3339` :: `2020-07-22T10:21:51-04:00`
func TimeStringLocal(t time.Time) string {
	return t.Format(time.RFC3339)
}

// UnixMsecNow :: Milliseconds since epoch now; {TIMESTAMP}mmm.
func UnixMsecNow() int64 {
	return time.Now().UnixNano() / int64(time.Millisecond)
}

// UnixMsecAtTime :: Milliseconds since epoch at provided Time; {TIMESTAMP}mmm.
func UnixMsecAtTime(thisTime time.Time) int64 {
	return thisTime.UnixNano() / int64(time.Millisecond)
}

// TimeToUnixMsec ...
func TimeToUnixMsec(t time.Time) int64 {
	return t.UnixNano() / int64(time.Millisecond)
}

// TimeToUnixSec ...
func TimeToUnixSec(t time.Time) int64 {
	return t.UnixNano() / int64(time.Second)
}

// Int64ToBytes ...
func Int64ToBytes(n int64) []byte {
	cn := make([]byte, 8)
	binary.LittleEndian.PutUint64(cn, uint64(n))
	return cn
}

// BytesToString @ zero-copy safely https://github.com/golang/go/issues/25484
func BytesToString(bytes []byte) (s string) {
	slice := (*reflect.SliceHeader)(unsafe.Pointer(&bytes))
	str := (*reflect.StringHeader)(unsafe.Pointer(&s))
	str.Data = slice.Data
	str.Len = slice.Len
	runtime.KeepAlive(&bytes) // this line is essential.
	return s
}

// BytesToHex ...
func BytesToHex(bb []byte) string {
	return fmt.Sprintf("%x\n", bb)
}

// Int64ToString ...
func Int64ToString(i int64) string {
	return strconv.FormatInt(i, 10)
}

// Int64ToString ...
func Int64ToString(i int64) string {
	return strconv.FormatInt(i, 10)
}

// CheckSumSHA1 ...
func CheckSumSHA1(bb []byte) string {
	return fmt.Sprintf("%x\n", sha1.Sum(bb))
}

// @ Mattermost  https://sourcegraph.com/github.com/mattermost/mattermost-server/-/blob/model/utils.go#L168
