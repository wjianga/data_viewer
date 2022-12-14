library(BioCircos)

draw_circosplot <- function(build, snv_data, cnv_data, sv_data) {
  GRCh38.chr.len <- c(248956422, 242193529, 198295559, 190214555,
                      181538259, 170805979, 159345973, 145138636, 138394717,
                      133797422, 135086622, 133275309, 114364328, 107043718,
                      101991189, 90338345, 83257441, 80373285, 58617616,
                      64444167, 46709983, 50818468, 156040895, 57227415)
  
  GRCh37.chr.len <- c(249250621, 243199373, 198022430, 191154276,
                      180915260, 171115067, 159138663, 146364022, 141213431,
                      135534747, 135006516, 133851895, 115169878, 107349540,
                      102531392, 90354753, 81195210, 78077248, 59128983,
                      63025520, 48129895, 51304566, 155270560, 59373566)
  
  GRCh36.chr.len <- c(247249719, 242951149, 199501827, 191273063,
                      180857866, 170899992, 158821424, 146274826, 140273252,
                      135374737, 134452384, 132349534, 114142980, 106368585,
                      100338915, 88827254, 78774742, 76117153, 63811651,
                      62435964, 46944323, 49691432, 154913754, 57772954)
  
  names(GRCh38.chr.len) <- c(1:22, "X", "Y")
  names(GRCh37.chr.len) <- c(1:22, "X", "Y")
  names(GRCh36.chr.len) <- c(1:22, "X", "Y")
  
  if (build == "GRCh38/hg38") {
    reference = "GRCh38.chr.len"
  } else if (build == "GRCh37/hg19") {
    reference = "GRCh37.chr.len"
  } else if (build == "GRCh36/hg18") {
    reference = "GRCh36.chr.len"
  }
  
  
  snv <- snv_data %>% 
    filter(Variant_Type == "SNP") %>% 
    dplyr::select(Chromosome, Start_Position) %>% 
    dplyr::mutate(start = floor(Start_Position / 10000000) * 10000000, end = start + (10000000)) %>% 
    dplyr::group_by(Chromosome, start, end) %>% 
    dplyr::summarize(start = start, end = end, count = n()) %>% 
    as.data.frame()
  
  barTracks = BioCircosBarTrack("myBar", 
                                chromosomes = snv$Chromosome,
                                starts = snv$start,
                                ends = snv$end,
                                values = snv$count,
                                color = "#12ad10",
                                minRadius = 0.7,
                                maxRadius = 0.95)
  
  
  cnv <- cnv_data %>% 
    dplyr::mutate(Chromosome = sapply(.$Chromosome,
                               str_remove,
                               "chr"))
  
  # cnvTrack = BioCircosCNVTrack("myCNV",
  #                              chromosomes = as.character(cnv$Chromosome),
  #                              starts = cnv$Start_Position,
  #                              ends = cnv$End_Position,
  #                              # values = cnv$Reads_Ratio,
  #                              values = cnv$test,
  #                              minRadius = 0.5,
  #                              maxRadius = 0.6)
  
  cnvTrack = BioCircosSNPTrack("myCNV",
                               chromosomes = as.character(cnv$Chromosome),
                               positions = (cnv$Start_Position + cnv$End_Position) / 2,
                               values = cnv$Reads_Ratio,
                               colors = ifelse(cnv$Reads_Ratio >= 1, "red", "blue"),
                               minRadius = 0.45,
                               maxRadius = 0.65)
  
  sv <- sv_data %>% 
    filter(MUTATION_TYPE != "intrachromosomal deletion") %>% 
    dplyr::select("DESCRIPTION") %>% 
    separate(col = everything(),
             into = c("start", "end"),
             sep = "_") %>% 
    separate(col = start,
             into = c("Chr1", "Start1"),
             sep = ":") %>% 
    separate(col = end,
             into = c("Chr2", "Start2"),
             sep = ":") %>% 
    dplyr::mutate(Chr1 = sapply(.$Chr1, str_remove, "chr"),
           Chr2 = sapply(.$Chr2, str_remove, "chr"),
           Start1 = sapply(.$Start1, str_remove_all, "[a-z.]+"),
           Start2 = sapply(.$Start2, str_remove_all, "[a-z]+")) %>% 
    drop_na()
  
  svTrack = BioCircosLinkTrack("mySV",
                               gene1Chromosomes = sv$Chr1,
                               gene1Starts = as.numeric(sv$Start1),
                               gene1Ends = as.numeric(sv$Start1) + 1000,
                               gene2Chromosomes = sv$Chr2,
                               gene2Starts = as.numeric(sv$Start2),
                               gene2Ends = as.numeric(sv$Start2) + 1000,
                               maxRadius = 0.4,
                               color = "#aa4ede")
  
  tracks = svTrack + BioCircosBackgroundTrack("svBG",
                                              minRadius = 0,
                                              maxRadius = 0.4,
                                              borderColors = "#fc8c03",
                                              fillColors = "#f0f8fc",
                                              borderSize = 0) + 
    cnvTrack + BioCircosBackgroundTrack("cnvBG",
                                               minRadius = 0.45,
                                               maxRadius = 0.65,
                                               borderColors = "#AAAAAA",
                                               fillColors = "#e0dcbf",
                                               borderSize = 0.5) +
    barTracks + BioCircosBackgroundTrack("barBG",
                                         minRadius = 0.70,
                                         maxRadius = 0.95,
                                         borderColors = "#AAAAAA",
                                         fillColors = "#eddfdf",
                                         borderSize = 0.6)
    
  
  
  BioCircos(tracks,
            genome = get(reference),
            chrPad = 0.05,
            displayGenomeBorder = F,
            genomeTicksDisplay = F)
}

# setwd("/Users/alan/Downloads/files")
# 
# snv = read.csv("./SNV_201T_edited.csv")
# sv = read.csv("./SV_CRC3.csv")
# cnv = read.csv("./CNV_edited.csv")
# 
# cnv <- rbind(cnv, cnv)
# 
# cnv <- cnv %>% 
#   mutate(Chromosome = sample(c(1:22, "X", "Y"), size = nrow(cnv), replace = TRUE)) %>% 
#   mutate(Start_Position = sample(GRCh38.chr.len[22]:GRCh38.chr.len[23], nrow(cnv), replace = TRUE))
# 
# draw_circosplot("GRCh38/hg38", snv, cnv, sv)

