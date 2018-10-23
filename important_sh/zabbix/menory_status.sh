#!/bin/bash
MemTotal(){
	awk '/^MemTotal/{print $2}' /proc/meminfo
}
MemFree(){
	awk '/^MemFree/{print $2}' /proc/meminfo
}
Dirty(){
	awk '/^Dirty/{print $2}' /proc/meminfo
}
Buffers(){
	awk '/^Buffers/{print $2}' /proc/meminfo
}
Cached(){
	awk '/^Cached/{print $2}' /proc/meminfo
}
Active(){
	awk '/^Active/{print $2}' /proc/meminfo
}
Inactive(){
	awk '/^Inactive/{print $2}' /proc/meminfo
}
SwapFree(){
	awk '/^SwapFree/{print $2}' /proc/meminfo
}
$1
