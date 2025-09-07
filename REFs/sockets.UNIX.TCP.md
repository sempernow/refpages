# [Sockets](https://www.digitalocean.com/community/tutorials/understanding-sockets "DigitalOcean 2021") | [UNIX Domain Socket (IPC)](https://en.wikipedia.org/wiki/Unix_domain_socket) | [Network Socket](https://en.wikipedia.org/wiki/Network_socket)

Enable inter-process communication (IPC) between programs running on a server, or between programs running on separate servers. Communication between servers relies on network sockets, which use the Internet Protocol (IP) to encapsulate and handle sending and receiving data.

Network sockets on both clients and servers are referred to by their socket address. An address is a unique combination of a transport protocol like the Transmission Control Protocol (TCP) or User Datagram Protocol (UDP), an IP address, and a port number. A network socket is effectively a network port (location) as seen from inside the target node (machine). 

> The server _listens_ (passive socket); the client _connects_ (active socket).

##  Socket Types

- TCP Stream Sockets use TCP as the underlying protocol.
- UDP Datagram Sockets
- [Unix Domain Sockets](https://medium.com/swlh/getting-started-with-unix-domain-sockets-4472c0db4eb1 "Getting Started With Unix Domain Sockets @ 2020")
    - Use local files, instead of network interfaces and IP packets, to send and receive data.  

## Utilities 

- [`socat(1)`](https://linux.die.net/man/1/socat "man page @ linux.die.net")  : SOcket `cat`; Multipurpose relay; establishes _two bidirectional byte streams_ and transfers data between them. Streams can be constructed from a large set of different types of data sinks and sources; lots of address options may be applied to the streams; used for many different purposes.
    - The life cycle of a `socat` instance typically consists of four phases.
        1. In the init phase, the command line options are parsed and logging is initialized
        1. The first address and then second address are opened. These steps are usually blocking; thus, especially for complex address types like SOCKS, connection requests or authentication dialogs must be completed before the next step is started.
        1. In the transfer phase, `socat` watches both `streamscq` read and write file descriptors; when data is available on one side and can be written to the other side, socat reads it, performs newline character conversions if required, and writes the data to the write file descriptor of the other stream, then continues waiting for more data in both directions.
        1. When one of the streams effectively reaches `EOF`, the closing phase begins; the `EOF` condition is transfered to the other stream, i.e. tries to shutdown only its write stream, giving it a chance to terminate gracefully. For a defined time `socat` continues to transfer data in the other direction, but then closes all remaining channels and terminates. 
- [`ss(8)`](https://linux.die.net/man/8/ss "man page @ linux.die.net") : socket statistics; newer and similar to [`netstat(8)`](https://linux.die.net/man/8/netstat "man page @ linux.die.net") utility.
- [`nc(1)`](https://linux.die.net/man/1/nc "man page @ linux.die.net") : AKA `netcat`; arbitrary TCP and UDP connections and listens; just about anything involving TCP or UDP. It can open TCP connections, send UDP packets, listen on arbitrary TCP and UDP ports, do port scanning, and deal with both IPv4 and IPv6. Unlike `telnet(1)`, `nc` scripts nicely, and separates `STDERR` from `STDOUT`. 


## Use [`socat(1)`](http://rpm.pbone.net/manpage_idpl_25675711_numer_1_nazwa_socat.html "rpm.pbone.net")

```ini
# Usage syntax
socat [options] <address> <address>
# <address>
protocol:ip:port
```

## [TCP-based Stream Sockets](https://www.digitalocean.com/community/tutorials/understanding-sockets#what-is-a-stream-socket "DigitalOcean 2021")

Stream sockets are connection oriented; packets sent to and received from a network socket are delivered by the host operating system in order for processing by an application. Network based stream sockets typically use the Transmission Control Protocol (TCP) to encapsulate and transmit data over a network interface.

TCP is designed to be a reliable network protocol that _relies on a stateful connection_. Data that is sent by a program using a TCP-based stream socket will be successfully received by a remote system (assuming there are no routing, firewall, or other connectivity issues). TCP packets can arrive on a physical network interface in any order. In the event that packets arrive out of order, the network adapter and host operating system will ensure that they are reassembled in the correct sequence for processing by an application.

A typical use for a TCP-based stream socket would be for a web server like Apache or Nginx handling HTTP requests on port `80`, or HTTPS on port `443`. For HTTP, a socket address would be similar to `203.0.113.1:80`, and for HTTPS it would be something like `203.0.113.1:443`.

### Creating TCP-based Stream Sockets

Emulate a web server listening for HTTP requests on port `8080` (the alternative HTTP port); create two TCP-based sockets that are listening for connections on port `8080` using IPv4 and IPv6 interfaces:

```bash
socat TCP4-LISTEN:8080,fork /dev/null &
socat TCP6-LISTEN:8080,ipv6only=1,fork /dev/null &
```
- `TCP4-LISTEN:8080` and `TCP6-LISTEN:8080` _args_ are protocol type and port number to use; creates TCP sockets on port `8080` on all IPv4 and IPv6 interfaces, and listens to each socket for incoming connections. Valid port range is `0` to `65535`.
- `fork` _option_ prevents the `socat` process from termating after it handles a connection.
- `/dev/null` path is used here in place of what would be the _remote socket address_; prints (`cat`) incoming input to that file, which silently discards it.
- `ipv6only=1` _flag_ is used for the IPv6 socket to tell the operating system that the socket is not configured to send packets to IPv4-mapped IPv6 addresses. Without this flag, socat will bind to both IPv4 and IPv6 addresses.
- `&` _character_ instructs the shell to run the command (process) in the background, so we can invoke other commands on this terminal to examine the socket.

### Examining TCP-based Stream Sockets

Show socket statistics

```bash
ss -tln
```
```text
State          Recv-Q         Send-Q     Local Address:Port    Peer Address:Port   Process
LISTEN         0              5          0.0.0.0:8080          0.0.0.0:*
LISTEN         0              5           [::]:8080             [::]:*
...
```
- The `Local` field, `0.0.0.0:8080`, shows the IPv4 TCP socket is listening on all available IPv4 interfaces on port `8080`. A service that is only listening on a specific IPv4 address will show only that IP in that field, e.g., `203.0.113.1:8080` . Similarly for the IPv6 TCP socket. 
- "`::`" is IPv6 addresss of all zeros.
    - Example report at `Local` field if listening to a specific IPv6 address: 
    `[2604:a880:400:d1::3d3:6001]:8080`
- Use`-4` and `-6` _flags_ to examine only one (IPv4 or IPv6). 
    ```bash
    ss -4 -tln
    ```
    - `t` _flag_ filters out all but for TCP sockets.
    - `l` _flag_ filters out all but for listening sockets. 
    Without this flag, all TCP connections would be displayed, which would include things like SSH, clients that may be connected to a web-server, or connections that your system may have to other servers.
    - `n` _flag_ reports port numbers instead of service names, e.g., `8080` is `http-alt`.

### Connecting to TCP-Based Stream Sockets

Connect to the IPv4 socket, created to listen on all interfaces, over the local loopback address.

```bash
nc -4 -vz 127.0.0.1 8080
```
```text
Connection to 127.0.0.1 8080 port [tcp/http-alt] succeeded!
```

- `-4` _flag_ tells netcat to use IPv4.
- `-v` _flag_ is used to print verbose output to your terminal.
- `-z` _option_ ensures that `netcat` connects to the socket without sending any data.
- The local loopback `127.0.0.1` IP address is used since your system will have its own unique IP address. If you know the IP for your system you can test using that as well. For example, if your system’s public or private IP address is 203.0.113.1 you could use that in place of the loopback IP.
```bash
nc -4 -vz 10.0.100.52 8080
```

Similarly for IPv6 connection

```bash
nc -6 -vz ::1 8080
```
- `::1` is IPv6 loopback.

#### Cleanup : Disconnect/Delete Sockets

Bring each background socket process (job) to the foreground and kill it; 
first display all by number (`jobs`), 
then bring each to foreground (`fg %$n`), killing each in turn (`CTRL-C`) .

```bash
/mnt/shared # jobs
[2]+  Running                    socat TCP6-LISTEN:8080,ipv6only=1,fork /dev/null
[1]-  Running                    socat TCP4-LISTEN:8080,fork /dev/null
/mnt/shared # fg %2
socat TCP6-LISTEN:8080,ipv6only=1,fork /dev/null    # CTRL-C
/mnt/shared # fg %1
socat TCP4-LISTEN:8080,fork /dev/null               # CTRL-C
/mnt/shared # jobs
/mnt/shared #
```

## [Datagram Sockets](https://www.digitalocean.com/community/tutorials/understanding-sockets#what-is-a-datagram-socket "DigitalOcean 2021")

Datagram sockets are connectionless, which means that packets sent and received from a socket are _processed individually_ by applications. Network-based datagram sockets typically use the User Datagram Protocol (UDP) to encapsulate and transmit data.

UDP _does not encode sequence information_ in packet headers, and there is _no error correction_ built into the protocol. Programs that use datagram-based network sockets must build in their own error handling and data ordering logic to ensure successful data transmission.

UDP sockets are commonly used by Domain Name System (DNS) servers. By default, DNS servers use port `53` to send and receive queries for domain names. An example UDP socket address for a DNS server would be similar to `203.0.113.1:53`.

>Note: The protocol (TCP/UDP) is not included in the human-readable version of the socket address, but operating systems differentiate socket addresses by including TCP and UDP protocols as part of the address. So a human-readable socket address like `203.0.113.1:53` could be using either protocol. Tools like `ss`, and the older `netstat` utility, are used to determine which kind of socket is being used.

The Network Time Protocol (NTP) uses a UDP socket on port `123` to synchronize clocks between computers. An example UDP socket for the NTP protocol would be `203.0.113.1:123`.

### Creating Datagram Sockets

Emulate an NTP server listening for requests on UDP port `123` using sockets. Then examine them using the `ss` and `nc` commands.

First create two UDP sockets that are listening for connections on port `123`, 
using IPv4 and IPv6 interfaces:

```bash
socat UDP4-LISTEN:123,fork /dev/null &
socat UDP6-LISTEN:123,ipv6only=1,fork /dev/null &
```
- Privileged user (`sudo`) required to create ports `0-1024` .

### Examining Datagram Sockets

Show socket statistics

```bash
ss -uln |grep 123
```
```text
UNCONN 0      0            0.0.0.0:123        0.0.0.0:*
UNCONN 0      0               [::]:123           [::]:*
```

### Testing Datagram Sockets

Connect 

```bash
nc -4 -u -vz 127.0.0.1 123
```
```text
Connection to 127.0.0.1 123 port [udp/ntp] succeeded!
```
- `-u` to connect per UPD instead of (default) TCP
- See TCP section for explanation of other options.

Cleanup using same method as with TCP Sockets

## [Unix Domain Socket](https://www.digitalocean.com/community/tutorials/understanding-sockets#what-is-a-unix-domain-socket "DigitalOcean 2021") | [Wikipedia](https://en.wikipedia.org/wiki/Unix_domain_socket "Wikipedia : Unix Domain Socket")

### About 

>A Unix domain socket aka UDS or IPC socket (inter-process communication socket) is a data communications endpoint for exchanging data between processes executing on the same host operating system; UDS _data is exchanged between programs directly_ in the OS kernel via files on the host filesystem; programs read and write to their shared socket file, _bypassing network based sockets and protocols entirely_. It is also referred to by its address family `AF_UNIX`. UDS may be stream-based or datagram-based. Valid socket types in the UNIX domain are:

- `SOCK_STREAM` (compare to TCP) – for a stream-oriented socket
- `SOCK_DGRAM` (compare to UDP) – for a datagram-oriented socket that preserves message boundaries (as on most UNIX implementations, UNIX domain datagram sockets are always reliable and don't reorder datagrams)
- `SOCK_SEQPACKET` (compare to SCTP) – for a sequenced-packet socket that is connection-oriented, preserves message boundaries, and delivers messages in the order that they were sent

The Unix domain socket facility is a standard component of POSIX operating systems.

The API for Unix domain sockets is similar to that of an Internet socket, but rather than using an underlying network protocol, ___all communication occurs entirely within the operating system kernel___.

UDS is used widely by database systems that do not need to be connected to a network interface; MySQL on Ubuntu defaults to using a file named `/var/run/mysqld/mysql.sock` for communication with local clients. Clients read from and write to the socket, as does the MySQL server itself.

PostgreSQL is another database system that uses a socket for local, non-network communication. Typically it defaults to using `/run/postgresql/.s.PGSQL.5432` as its socket file.

### Creating Unix Domain Sockets

Create both stream-based and datagram-based Unix Domain Sockets without using TCP or UDP to encapsulate data to send over networks. 

```bash
# Create stream-based UDS
socat UNIX-LISTEN:/tmp/stream.sock,fork /dev/null &
# Create datagram-based UDS
socat UNIX-RECVFROM:/tmp/datagram.sock,fork /dev/null &
```
- Both commands specify a filename after the "`:`" separator. The filename is _the address_ of the socket itself. The name of a socket is arbitrary but it helps if it is descriptive when you are troubleshooting.
- `fork` _option_ prevents the `socat` process from termating after it handles a connection.
- `/dev/null` path is used here in place of what would be the _remote socket address_; prints (`cat`) incoming input to that file, which silently discards it.
- `&` _character_ instructs the shell to run the command (process) in the background, so we can invoke other commands on this terminal to examine the socket.

### Examining Unix Domain Sockets

```bash
ss -xln 
```
```text
Netid         State       Recv-Q    Send-Q   Local Address:Port          Peer Address:Port   Process
u_str         LISTEN      0         5        /tmp/stream.sock 269122     * 0
u_dgr         UNCONN      0         0        /tmp/datagram.sock 269288   * 0
...
```
- `-x` _flag_ to filter out all but for domain sockets.
- `u_str` indicates the UDS is stream-based.
- `u_dgr` indicates the UDS is datagram-based.

Since UDSs are files, the usual Linux user and group permissions and access controls can be used to restrict who can connect to the socket. You can also use filesystem tools like `ls`, `mv`, `chown` and `chmod` to examine and manipulate UDS files. Tools like `SELinux` can also be used to label UDS files with different security contexts.

To check if a file is a UDS socket, use the `ls`, `file` or `stat` utilities. However, it is important to note that none of these tools can determine if a UDS is stream or datagram-based. Use the `ss` tool for the most complete information about a Unix Domain Socket.

@ `ls`  

```bash
/mnt/shared # ls /tmp
...
srwxr-xr-x    1 root     root           0 Dec  8 14:34 datagram.sock
srwxr-xr-x    1 root     root           0 Dec  8 14:33 stream.sock
```
@ `stat`

```bash
/mnt/shared # stat /tmp/stream.sock /tmp/datagram.sock
  File: /tmp/stream.sock
  Size: 0               Blocks: 0          IO Block: 4096   socket
Device: 9eh/158d        Inode: 1366937     Links: 1
Access: (0755/srwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2022-12-08 14:33:03.611342000 -0500
Modify: 2022-12-08 14:33:03.611342000 -0500
Change: 2022-12-08 14:33:03.611342000 -0500
  File: /tmp/datagram.sock
  Size: 0               Blocks: 0          IO Block: 4096   socket
Device: 9eh/158d        Inode: 1366942     Links: 1
Access: (0755/srwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2022-12-08 14:34:06.231657000 -0500
Modify: 2022-12-08 14:34:06.231657000 -0500
Change: 2022-12-08 14:34:06.231657000 -0500
```

### Connecting to Unix Domain Sockets

```bash
# Connect to stream-based UDS
nc -U -z /tmp/stream.sock
# Connect to datagram-based UDS
nc -uU -z /tmp/datagram.sock
```

Cleanup using same method as with TCP Sockets

## [File Descriptors](https://en.wikipedia.org/wiki/File_descriptor)

In Unix and Unix-like computer operating systems, a file descriptor (`FD`, less frequently `fildes`) is ___a process-unique identifier___ (handle) for a file or other input/output resource, such as a pipe or network socket.

File descriptors typically have non-negative integer values, with negative values being reserved to indicate "no value" or error conditions.

File descriptors are a part of the POSIX API. Each Unix process (except perhaps daemons) should have three standard POSIX file descriptors, corresponding to the three standard streams:

| #|Name|symbolic constant `<unistd.h>`|file stream `<stdio.h>`|
|---|---|---|---|
| `0`|Standard input|`STDIN_FILENO`|`stdin`|
| `1`|Standard output|`STDOUT_FILENO`|`stdout`|
| `2`|Standard error|`STDERR_FILENO`|`stderr`|

### [File Descriptor 3](https://unix.stackexchange.com/questions/181183/opening-a-socket-in-kali-linux-using-bash-scripts/ "StackExchange.com 2015")


```bash
# Needn't exist
☩ ls /dev/tcp                                                             
ls: cannot access '/dev/tcp': No such file or directory                   

# Create
☩ exec 3<>/dev/tcp/google.com/80                                          

# Not seen as either a file or directory
☩ ls /dev/tcp                                                             
ls: cannot access '/dev/tcp': No such file or directory                   

# Send GET request
☩ echo -e "GET / HTTP/1.1\n\r" >&3                                        

# Read response
☩ cat <&3                                                                 
HTTP/1.1 200 OK                                                           
...                                      
Content-Type: text/html; charset=ISO-8859-1                               
...                                                                                              
Transfer-Encoding: chunked  

539e                                                                      
<!doctype html><html ...
```




### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

