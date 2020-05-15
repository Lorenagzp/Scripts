import sys
import dropbox
dbx = dropbox.Dropbox('4H0Ot5dhdUsAAAAAAE0Zhy-KMWRoU_rthRn_Ir9TerwO4NEdk86IdE_ylo1-j19z')
dbx.users_get_current_account()
for entry in dbx.files_list_folder('').entries:
    print(entry.name)

#dbx.files_upload
#dbx.files_get_metadata
