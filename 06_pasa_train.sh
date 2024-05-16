#01_RNAseq_seqclean.sh
wd=`pwd`
cd $wd
/public/home/liyongxin/wangzhongkai/soft/pasa/PASApipeline-v2.5.2/bin/seqclean Bridger.fasta -c 5
perl accession_extractor.pl Bridger.fasta > Bridger.fasta.accs

#02.PASA_alignAssembly.sh
perl /public/home/liyongxin/wangzhongkai/soft/pasa/PASApipeline-v2.5.2/Launch_PASA_pipeline.pl \
 -c pasa.alignAssembly.Template.txt -C -r -R -g jjx.hic.chr.fasta \
 -t Bridger.fasta.clean -T -u Bridger.fasta  \
 --ALIGNERS minimap2 --TRANSDECODER --CPU 30

#03.ORF_and_gene_prodict.sh
cd $wd
/public/home/liyongxin/wangzhongkai/soft/pasa/PASApipeline-v2.5.2/scripts/pasa_asmbls_to_training_set.dbi --pasa_transcripts_fasta  my_pasa.assemblies.fasta --pasa_transcripts_gff3 my_pasa.pasa_assemblies.gff3

#04.pasa_extract_best_candidate_geneModels.sh
cd $wd
/home/script/chenlf/pasa_extract_best_candidate_geneModels.pl pasa0.assemblies.fasta.transdecoder.genome.gff3 pasa0.assemblies.fasta.transdecoder.cds 3 900 0.60 0.95 0.95 > best_candidates.gff3
/home/soft/EVidenceModeler-1.1.1/EvmUtils/gff3_file_to_proteins.pl best_candidates.gff3 mantouxie.repeat_without_trf.sm.fa prot >best_candidates.fasta
/home/script/chenlf/remove_redundant_high_identity_genes.pl best_candidates.gff3 best_candidates.fasta 10 0.70 > best_candidates.lowIdentity.gff3 2>remove_redundant_high_identity_genes.log

#05.cdhit.sh
cd $wd
cd-hit -i ./best_candidates.fasta -o ./best_candidates.fasta.nr -M 80000 -c 0.7 -n 5 -T 30

#06.gff3_2_gff.sh
/public/home/liyongxin/wangzhongkai/script/chang_gff3_to_gff.pl best_candidates.gff3 best_candidates.gff

#07.training.sh
cd $wd
autoAugTrain.pl --genome=jjx.hic.chr.fasta --trainingset=./best_candidates.gff --species=jijuxie.chr --useexisting
