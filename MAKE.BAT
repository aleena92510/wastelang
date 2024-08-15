del make.log
del core.com
del wastelng.com
debug.com < core.asm
echo "core.com generated"
core.com < lib.fth
echo "wastelng.com generated"
wastelng.com < test.fth > make.log
type make.log
