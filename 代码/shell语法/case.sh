#!/bin/bash
echo "please input a number in 1-3"
read nu
case $nu in
1)
echo "you are beautiful"
;;
2)
echo "you are ugly"
;;
3)
echo "you are handsome"
;;
*)
echo "what do you want to do ?"
;;
esac

