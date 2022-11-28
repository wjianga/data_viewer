plot_cnv <- function(cnv_file, start_pos, end_pos, chromosome, sample) {
   subset_cnv <- cnv_file %>%
     filter(Chromosome == chromosome) %>%
     filter(Start_Position >= start_pos & End_Position <= end_pos) %>%
     filter(Sample == sample)

   ggplot(subset_cnv) +
     geom_point(aes(x = Start_Position, y = Reads_Ratio, color = Hugo_Symbol), size = 4) +
     geom_abline(slope = 0, intercept = 1, color = "red") +
     theme_bw() +
     labs(color = "Hugo_Symbol",
          x = "Coordinate",
          y = "Reads Ratio")
}
# 
# test = read.csv("/Users/alan/Downloads/files/CNV_edited.csv")
# 
# plot_cnv(test, 0, 100000, 1, "XG7")
