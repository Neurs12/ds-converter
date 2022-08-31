import xlrd, click

@click.command()
@click.option("--path")
@click.option("--convert")
@click.option("--saveat")
@click.option("--extratext")
@click.option("--namesetting")
@click.option("--sort")
def main(path, convert, saveat, extratext, namesetting, sort):
    if convert != None and saveat != None and sort != None and namesetting != None:
        wsinp = xlrd.open_workbook(convert, ignore_workbook_corruption=True).sheet_by_index(0)
        names = []
        phones = {}
        index = 7

        try:
            while True:
                names.append(wsinp.cell_value(rowx=index, colx=4))
                index += 1
        except: pass

        max_index = len(names) - 1
        tmp = 0
        index = 7

        while index <= max_index + 8:
            try:
                if wsinp.cell_value(rowx=index, colx=31) != "":
                    phones.update({names[tmp]: wsinp.cell_value(rowx=index, colx=31)})
                    index += 1
                    tmp += 1
                    continue
            except:
                pass
            try:
                if wsinp.cell_value(rowx=index, colx=34) != "":
                    phones.update({names[tmp]: wsinp.cell_value(rowx=index, colx=34)})
                    index += 1
                    tmp += 1
                    continue
            except:
                pass
            try:
                if wsinp.cell_value(rowx=index, colx=33) != "":
                    phones.update({names[tmp]: wsinp.cell_value(rowx=index, colx=33)}) != ""
                    index += 1
                    tmp += 1
                    continue
            except:
                pass

            index += 1
            tmp += 1

        if not saveat.endswith(".vcf"):
            saveat += ".vcf"

        with open(saveat, "w+", encoding="utf-8") as save:
            if namesetting == "Họ và tên học sinh":
                if sort == "Tên phụ đứng trước":
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write(f"BEGIN:VCARD\nVERSION:3.0\nFN:{extratext} {names[i]}\nN:{extratext} {names[i]};;;;\nTEL;TYPE=CELL:{phones[names[i]]}\nEND:VCARD\n")
                else:
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write(f"BEGIN:VCARD\nVERSION:3.0\nFN:{names[i]} {extratext}\nN:{names[i]} {extratext};;;;\nTEL;TYPE=CELL:{phones[names[i]]}\nEND:VCARD\n")
            if namesetting == "Tên đệm + tên học sinh":
                if sort == "Tên phụ đứng trước":
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write("BEGIN:VCARD\nVERSION:3.0\nFN:{} {}\nN:{} {};;;;\nTEL;TYPE=CELL:{}\nEND:VCARD\n".format(extratext, " ".join(names[i].split(" ")[-2:]), extratext, " ".join(names[i].split(" ")[-2:]), phones[names[i]]))
                else:
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write("BEGIN:VCARD\nVERSION:3.0\nFN:{} {}\nN:{} {};;;;\nTEL;TYPE=CELL:{}\nEND:VCARD\n".format(" ".join(names[i].split(" ")[-2:]), extratext, " ".join(names[i].split(" ")[-2:]), extratext, phones[names[i]]))

            if namesetting == "Chỉ tên học sinh":
                if sort == "Tên phụ đứng trước":
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write("BEGIN:VCARD\nVERSION:3.0\nFN:{} {}\nN:{} {};;;;\nTEL;TYPE=CELL:{}\nEND:VCARD\n".format(extratext, names[i].split(" ")[-1], extratext, names[i].split(" ")[-1], phones[names[i]]))
                else:
                    for i in range(len(names)):
                        if names[i] in phones:
                            save.write("BEGIN:VCARD\nVERSION:3.0\nFN:{} {}\nN:{} {};;;;\nTEL;TYPE=CELL:{}\nEND:VCARD\n".format(names[i].split(" ")[-1], extratext, names[i].split(" ")[-1], extratext, phones[names[i]]))
                        
        print(f"success {len(phones)}/{len(names)}", end="")
    else:
        wsinp = xlrd.open_workbook(path, ignore_workbook_corruption=True).sheet_by_index(0)
        try:
            if wsinp.cell_value(rowx=6, colx=4) == "Họ và tên" and wsinp.cell_value(rowx=6, colx=31) == "Điện thoại DĐ" and wsinp.cell_value(rowx=6, colx=33) == "Điện thoại bố" and wsinp.cell_value(rowx=6, colx=34) == "Điện thoại mẹ":
                print("cool", end="")
                return
            else:
                print("wrong_file_type", end="")
        except:
            print("wrong_file_type", end="")
            return

main()