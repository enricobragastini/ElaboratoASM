import os

bin_input   =   "asm/bin/in_1.txt"
bin_output  =   "asm/bin/out_1.txt"
postfix     =   "asm/bin/postfix"
istanza     =   "materiale/istanze/{}_{}.txt"


def copy_file(path1, path2):
    with open(path1, "r") as f1:
        with open(path2, "w") as f2:
            for line in f1:
                f2.write(line)


def test_istanza(i):
    copy_file(istanza.format("in", i), bin_input)
    os.system(postfix + " " + bin_input + " " + bin_output)


if __name__ == "__main__":
    for i in range(1, 6):
        print("Istanza #", i)
        test_istanza(i)

        print("Input string: \t\t", end='')
        with open(istanza.format("in", i), "r") as out:
            print(out.read())

        print("Expected value: \t", end='')
        with open(istanza.format("out", i), "r") as out:
            print(out.read())
        
        print("Calculated value: \t", end='')
        with open(bin_output, "r") as out:
            print(out.read())

        print("\n")


    