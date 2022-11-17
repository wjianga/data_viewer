plot_cnv <- function(cnv_file, start_pos, end_pos, chromosome) {
  subset_cnv <- cnv_file %>% 
    filter(Chromosome == chromosome) %>% 
    filter(Start_Position >= start_pos & End_Position <= end_pos)
  
  ggplot(subset_cnv) +
    geom_point(aes(x = Start_Position, y = Reads_Ratio, color = Common_CNV), size = 4) +
    theme_bw() +
    labs(color = "Common CNV",
         x = "Coordinate",
         y = "Reads Ratio")
}

