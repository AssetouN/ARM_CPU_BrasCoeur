AS_ARM = /usr/bin/arm-linux-gnu-as
LD_ARM = /usr/bin/arm-linux-gnu-ld
#AS_ARM = /usr/bin/arm-linux-gnueabihf-as
#LD_ARM = /usr/bin/arm-linux-gnueabihf-ld
CFLAGS = -march=armv2a
LD_FLAGS = -Bstatic -fix-v4bx

fic =test_inter_mult test_inter_mtrans test_inter test_interrupt test_mtrans_post_dec test_mtrans_pre_dec test_mtrans_post_inc test_mtrans_pre_inc test_tst test_rsb test_bic test_b test_mov test_mvn test_add test_shift test_rot test_rrx test_add_flags test_logic test_mul test_swp test_func_mult test_loadstore test_pgcd test_bloct test_mla

all : $(fic)

$(fic) : % : %.o
	${LD_ARM} ${LD_FLAGS} -T sections.lds -o $@ $<

%.o : %.s
	${AS_ARM} ${CFLAGS} -c $< -o $@

clean :
	rm -f $(fic) *.o
