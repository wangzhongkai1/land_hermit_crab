enzyme=DpnII
fastqfile1=/public/home/liyongxin/wangzhongkai/project/jijuxie/04_Hic/data_merge/all_R1.fq
fastqfile2=/public/home/liyongxin/wangzhongkai/project/jijuxie/04_Hic/data_merge/all_R2.fq
species=jjx
reference_path=/public/home/liyongxin/wangzhongkai/project/jijuxie/04_Hic/input.genome.fasta
thread=128
workdir=/public/home/liyongxin/wangzhongkai/project/jijuxie/04_Hic

################################################################################
echo 'step1 run_juicer'
cd $workdir
mkdir -p scripts fastq references references
cd fastq
ln -s $fastqfile1 $species'_R1.fastq'
ln -s $fastqfile2 $species'_R2.fastq'
cd ../
cd ../restriction
python $workdir/scripts/get_inres.py $enzyme $species $reference_path
cd ../references
cp -f $reference_path $species'.fa'
bwa index -a bwtsw $species'.fa'
python $workdir/scripts/get_length.py -i $workdir/references/$species'.fa' -o $species'.length'
cd ../scripts
bash $workdir/scripts/juicer.sh -d $workdir -D $workdir -S early -g $species -z $workdir/references/$species'.fa' -t $thread -s $enzyme -y $workdir/restriction/$species'_'$enzyme'.txt' -p $workdir/references/$species'.length'

###############################################################################
echo "run 3d_dna"
cd $workdir
mkdir -p 3d_dna
cd 3d_dna
bash /public/home/liyongxin/wangzhongkai/soft/3d-dna-201008/run-asm-pipeline.sh \
 -m haploid \
 -i 15000 \
 -r 3 \
 $workdir/references/$species'.fa' \
 $workdir/aligned/merged_nodups.txt
