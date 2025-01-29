# https-roadmap.sh-projects-server-stats
Goal of this project is to write a script to analyse server performance stats.

Requirements
You are required to write a script server-stats.sh that can analyse basic server performance stats. You should be able to run the script on any Linux server and it should give you the following stats:

### Total CPU usage

the initial think about how analyse the server performance stats is using de tool 'top'

```
man top
```

about to know the 'Total CPU usage' could to use 'id' time spent in the kernel idle handler that is a percentage

```
TASK and CPU States
       This portion consists of a minimum of two lines.  In an SMP
       environment, additional lines can reflect individual CPU state
       percentages.

       Line 1 shows total tasks or threads, depending on the state of
       the Threads-mode toggle.  That total is further classified
       according to task state as follows:
           displayed       process status (‘S’)
           ---------       --------------------
           running         R
           sleep           S + any remaining
           d-sleep         D
           stopped         T + t
           zombie          Z

       Line 2 shows CPU state percentages based on the interval since
       the last refresh.

       As a default, percentages for these individual categories are
       displayed.  Depending on your kernel version, the st field may
       not be shown.
           us : time running un-niced user processes
           sy : time running kernel processes
           ni : time running niced user processes
           id : time spent in the kernel idle handler
           wa : time waiting for I/O completion
           hi : time spent servicing hardware interrupts
           si : time spent servicing software interrupts
           st : time stolen from this vm by the hypervisor

       The ‘sy’ value above also reflects the time running a virtual cpu
       for guest operating systems, including those that have been
       niced.

       Beyond the first tasks/threads line, there are alternate CPU
       display modes available via the 4-way ‘t’ command toggle.  They
       show an abbreviated summary consisting of these elements:
                      a    b     c    d
           %Cpu(s):  75.0/25.0  100[ ... ]

       Where: a) is the ‘user’ (us + ni) percentage; b) is the ‘system’
       (sy + hi + si + guests) percentage; c) is the total percentage;
       and d) is one of two visual graphs of those representations.
       Such graphs also reflect separate ‘user’ and ‘system’ portions.

       If the ‘4’ command toggle is used to yield more than two cpus per
       line, results will be further abridged eliminating the a) and b)
       elements.  However, that information is still reflected in the
       graph itself assuming color is active or, if not, bars vs. blocks
       are being shown.

       See topic 4b. SUMMARY AREA Commands for additional information on
       the ‘t’ and ‘4’ command toggles.
```

the option of comand line that is interesting for the current specifications is

```
-b, --batch
          Starts top in Batch mode, which could be useful  for  sending  output
          from  top to other programs or to a file.  In this mode, top will not
          accept input and runs until the iterations limit you've set with  the
          `-n' command-line option or until killed.
```

using grep to filter the line of stats of CPU

```
grep "Cpu(s)" 
```

also using sed 

```
man sed
```
we use replacement with a regular expresion:

```
s/regexp/replacement/
              Attempt to match regexp against the pattern space.  If successful, replace that portion matched with replacement.  The replacement may contain the special character & to
              refer to that portion of the pattern space which matched, and the special escapes \1 through \9 to refer to the corresponding matching sub-expressions in the regexp.
```
de regular expresion that we use to catch the Idle cpu is:

```
 ".* \([0-9,]*\)%* id.*"
```

We have to take into account the notation that the decimal number has, whether with "," or with "."

```
top -bn1 | grep "Cpu(s)" | sed -n 's/.* \([0-9,]*\)%* id.*/\1/p' | awk '{print 100 - $1}'
```

### Total memory usage (Free vs Used including percentage)
to memory we will use free that displays  the  total  amount of free and used physical and swap memory in the system, as well as the buffers and caches used by the kernel. The information is gathered by parsing /proc/meminfo.
I use 
```
free -m | awk '/^Mem:/ {mem_total=$2; mem_available=$7} /^Inter:/ {inter_total=$2} END {print "Memoria Total :", mem_total + inter_total, "MB"; print "Memoria Libre (available):", mem_available, "MB"}
```

### Total disk usage (Free vs Used including percentage)
Using df 

```
df -h --total | awk '/^total/ {printf "Total disk: %s\nUsed disk: %s (%.2f%%)\nFree disk: %s (%.2f%%)\n", $2, $3, ($3/$2)*100, $4, ($4/$2)*100}'
```

### Top 5 processes by CPU usage
for to processes we will use "ps"

```
man ps
```

```
-e     Select all processes.

-o format
              User-defined format.  format is a single argument in the form of a blank-separated or comma-separated list, which offers a way to specify individual output columns.  The
              recognized keywords are described in the STANDARD FORMAT SPECIFIERS section below.  Headers may be renamed (ps -o pid,ruser=RealUser -o comm=Command) as desired.  If all
              column headers are empty (ps -o pid= -o comm=) then the header line will not be output.  Column width will increase as needed for wide headers; this may be used to widen
              up columns such as WCHAN (ps -o pid,wchan=WIDE-WCHAN-COLUMN -o comm).  Explicit width control (ps opid,wchan:42,cmd) is offered too.  The behavior of ps -o  pid=X,comm=Y
              varies  with  personality;  output  may  be  one  column  named  "X,comm=Y"  or two columns named "X" and "Y".  Use multiple -o options when in doubt.  Use the PS_FORMAT
              environment variable to specify a default as desired; DefSysV and DefBSD are macros that may be used to choose the default UNIX or BSD columns.


--sort spec
              Specify sorting order.  Sorting syntax is [+|-]key[,[+|-]key[,...]].  Choose a multi-letter key from the STANDARD FORMAT SPECIFIERS section.  The "+" is  optional  since
              default direction is increasing numerical or lexicographic order.  Identical to k.  For example: ps jax --sort=uid,-ppid,+pid


%cpu        %CPU      cpu  utilization  of  the process in "##.#" format.  Currently, it is the CPU time used divided by the time the process has been running (cputime/realtime
                             ratio), expressed as a percentage.  It will not add up to 100% unless you are lucky.  (alias pcpu).

comm        COMMAND   command  name  (only  the executable name).  The output in this column may contain spaces.  (alias ucmd, ucomm).  See also the args format keyword, the -f
                             option, and the c option.
                             When specified last, this column will extend to the edge of the display.  If ps can not determine display width, as when output is redirected (piped) into
                             a file or another command, the output width is undefined (it may be 80, unlimited, determined by the TERM variable, and so on).  The  COLUMNS  environment
                             variable or --cols option may be used to exactly determine the width in this case.  The w or -w option may be also be used to adjust width.

                          
pid         PID       a number representing the process ID (alias tgid).
```

To obtein the Top 5 only have to use head

```
man head
```

```
Print the first 10 lines of each FILE to standard output.  With more than one FILE, precede each with a header giving the file name.

-n, --lines=[-]NUM
              print the first NUM lines instead of the first 10; with the leading '-', print all but the last NUM lines of each file

```
the format output use awk using the fisrt line "header" (NR current record number in the total input stream.) and PID,PROCESS,%USE_CPU 


```
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_CPU: %.2f%%\n", $1, $2, $3}'
```

### Top 5 processes by memory usage
Like de top five of cpu but changing %cpu to %mem

```
ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_MEM: %.2f%%\n", $1, $2, $3}'
```


### Stretch goal: Feel free to optionally add more stats such as 
 to this part optionally we will use the tools uptime,who and the files ***/etc/os-release*** , ***/var/log/auth.log*** and ***/var/log/secure***
#### os version: 
```
cat /etc/os-release
```
#### uptime 
```
uptime | awk '{print $1}'
```
#### load average 
```
uptime | awk -F'load average:' '{print "Load average(1 min, 5 min, 15 min):" $2}'
```
#### logged in users
```
 who | awk '{printf "User: %-10s Terminal: %-10s Time: %-10s\n", $1, $2, $3}'
```
#### failed login attempts
```
cat /var/log/auth.log
```


```
#!/bin/bash


```

