import os
import shutil

root_src_dir = '/var/www/squid-reports/testing/'
root_target_dir = '/squidReports/'

operation= 'move' # 'copy' or 'move'

for src_dir, dirs, files in os.walk(root_src_dir):
    dst_dir = src_dir.replace(root_src_dir, root_target_dir)
    if not os.path.exists(dst_dir):
        os.mkdir(dst_dir)
    for file_ in files:
        src_file = os.path.join(src_dir, file_)
        dst_file = os.path.join(dst_dir, file_)
        if os.path.exists(dst_file):
            os.remove(dst_file)
        if operation is 'copy':
            shutil.copy(src_file, dst_dir)
        elif operation is 'move':
            shutil.move(src_file, dst_dir)

for dir in  os.listdir(root_src_dir):
        #print dir
        shutil.rmtree(root_src_dir+dir)
