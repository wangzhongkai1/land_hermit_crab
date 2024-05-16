#$1 genome file
if [ $# -ne 1 ]
then
        echo "usage: sh $0 genome file ## either absolute path or relative path is okay"
        exit
fi

echo start `date`
wd=`pwd`
genome_path=$1
denovo=$wd/../gff/denovo_prediction.gff3
homolog=$wd/../gff/homolog.gff3
trans=$wd/../gff/trans.gff3
cut -f 2 $denovo | sort | uniq | awk '{print "ABINITIO_PREDICTION\t"$0"\t1"}' > weights
cut -f 2 $homolog | sort | uniq | awk '{print "PROTEIN\t"$0"\t5"}' >> weights
cut -f 2 $trans | sort | uniq | awk '{print "TRANSCRIPT\t"$0"\t10"}' >> weights


genome=`basename $genome_path`
dir=`dirname $genome_path`
if [ $dir = "." ]
then
        genome_path2=$wd/$genome
else
        ln -s $genome_path
        genome_path2=$wd/$genome
fi

#echo start `date`
perl /public/home/liyongxin/wangzhongkai/soft/EVM/EVidenceModeler-1.1.1/EvmUtils/write_EVM_commands.pl \
--genome $genome_path2 \
 --weights $wd/weights \
 --gene_predictions $denovo \
 --protein_alignments $homolog \
 --transcript_alignments $trans \
 --output_file_name evm.out \
 --partitions partition/partitions_list.out > commands.list
echo end `date`
