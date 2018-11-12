#!/usr/bin/python
import sys, getopt
from datetime import date

def get_opt(argv):
    global g_file_title
    global g_file_label
    try:
        opts, args = getopt.getopt(argv,"t:l:",["title=","label="])
        print(opts)
        print(args)
    except getopt.GetoptError:
        print './create-markdown.py -t <title_name> -l <label>'
        sys.exit(2)

    for opt, arg in opts:
        if opt == '-h':
            print './create-markdown.py -t <title_name> -l <label>'
            sys.exit()
        elif opt in ("-t", "--title"):
            g_file_title = arg
        elif opt in ("-l", "--label"):
            g_file_label = arg

def creat_mkdown(title, label):
    today = str(date.today())
    file_name = today + "-" + title + ".md"
    title_with_space = title.replace("-", " ")
    f= open(file_name,"w+")
    f.write("---\n")
    f.write("layout" + ":\t" + "post\n")
    f.write("title" + ":\t" + "\"" + title_with_space + "\"\n")
    f.write("date" + ":\t" + today + "\n")
    f.write("tags" + ":\t" + "[\"" + label + "\"]\n")
    f.write("image" + ":\t" + "\"\"\n")
    f.write("---\n\n")
    f.write("\n")
    f.write(title_with_space + "\n===\n")
    f.close()

if __name__ == "__main__":
    get_opt(sys.argv[1:])
    print(g_file_title)
    print(g_file_label)
    creat_mkdown(g_file_title, g_file_label)
