#!/bin/bash

cd initrd
find . | cpio -H newc -o > ../bin/initrd.cpio
cd ..
cat bin/initrd.cpio | gzip > bin/initrd.igz
