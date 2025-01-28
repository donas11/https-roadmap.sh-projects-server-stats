# https-roadmap.sh-projects-server-stats
Goal of this project is to write a script to analyse server performance stats.

Requirements
You are required to write a script server-stats.sh that can analyse basic server performance stats. You should be able to run the script on any Linux server and it should give you the following stats:

* Total CPU usage

the initial think about how analyse the server performance stats is using de tool 'top'
'''
man top
'''
about to know the 'Total CPU usage' could to use 'id' time spent in the kernel idle handler that is a percentage
'''
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
'''

the option of comand line that is interesting for the current specifications is

'''
-b, --batch
          Starts top in Batch mode, which could be useful  for  sending  output
          from  top to other programs or to a file.  In this mode, top will not
          accept input and runs until the iterations limit you've set with  the
          `-n' command-line option or until killed.
'''

using grep to filter the line of stats of CPU

'''
grep "Cpu(s)" 
'''

also using sed 
'''
man sed
'''

'''
s/regexp/replacement/
              Attempt to match regexp against the pattern space.  If successful, replace that portion matched with replacement.  The replacement may contain the special character & to
              refer to that portion of the pattern space which matched, and the special escapes \1 through \9 to refer to the corresponding matching sub-expressions in the regexp.
'''
de regular expresion that we use to catch the Idle cpu is:
'''
 ".* \([0-9,]*\)%* id.*"
'''
We have to take into account the notation that the decimal number has, whether with "," or with "."

top -bn1 | grep "Cpu(s)" | sed -n 's/.* \([0-9,]*\)%* id.*/\1/p' | awk '{print 100 - $1}'


* Total memory usage (Free vs Used including percentage)





* Total disk usage (Free vs Used including percentage)
* Top 5 processes by CPU usage
* Top 5 processes by memory usage
Stretch goal: Feel free to optionally add more stats such as os version, uptime, load average, logged in users, failed login attempts etc.





```
#!/bin/bash


```

