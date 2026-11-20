import sys, shutil, ale_py, os
os.makedirs('/tmp/ssn',exist_ok=True); p='/tmp/ssn/%s.bin'%sys.argv[2]; shutil.copy(sys.argv[1],p)
a=ale_py.ALEInterface(); a.setLoggerMode(ale_py.LoggerMode.Error)
a.loadROM(p); print('loaded ok',flush=True)
