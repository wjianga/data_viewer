# data("TCGA.BC.cnv.2k.60")
# data("UCSC.hg19.chr")
# 
# hg38 = read.csv("GRCh38_hg38.csv")
# # hg19 = read.csv("GRCh37_hg19.csv")
# 
# # hg19_test = UCSC.hg19.chr %>% group_by(chrom) %>% summarize(chromStart = min(chromStart), chromEnd = max(chromEnd)) %>% mutate(option1 = 0, option2 = 0) %>% mutate(chrom = as.character(chrom)) %>% as.data.frame()
# 
# # sim.out = sim.circos()
# 
# # circos(R = 350, type = "h", mapping = simulated$seg.mapping, cir = segAnglePo(test, seg = test[, 1]), W = 40, col.v = 8, col = colors[2], B = T,
# #        print.chr.lab = T)
# 
# # circos(R = 400,
# #        xc = 500,
# #        yc = 500,
# #        cir = segAnglePo(test, seg = test[, 1]),
# #        W = 40,
# #        mapping = TCGA.BC.cnv.2k.60,
# #        type = "s",
# #        print.chr.lab = T,
# #        B = T)
# 
# seg.f <- hg38
# # seg.v <- TCGA.BC.cnv.2k.60
# # seg.num <- length(unique(seg.f[, 1]))
# 
# par(mar = c(2, 2, 2, 2))
# plot(c(1, 800), c(1, 800), type = "n", axes = F, xlab = "", ylab = "", main = "")
# 
# # seg.name <- paste("chr", 1:seg.num, sep = "")
# db <- segAnglePo(seg.f, seg = unique(seg.f[,1]))
# colors = rainbow(24, alpha = 0.5)
# 
# circos(R = 400,
#        cir = db,
#        type = "chr",
#        col = colors,
#        print.chr.lab = TRUE,
#        W = 10)
# 
# circos(R = 350,
#        cir = db,
#        type = "l",
#        col = colors[1],
#        lwd = 2,
#        mapping = TCGA.BC.cnv.2k.60,
#        B = TRUE,
#        W = 50)



############### BioCircos

library(BioCircos)

data("TCGA.PAM50_genefu_hg18")
# TCGA.PAM50_genefu_hg18

test_data = read.csv("./201T_SNV.csv")
cnv_data = read.csv("./cnv.txt", sep = "\t")
sv_data = read.csv("SV_CRC3.csv")

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

names(GRCh38.chr.len) <- c(1:22, "X", "Y")
names(GRCh37.chr.len) <- c(1:22, "X", "Y")

# BioCircos(genome = GRCh37.chr.len)

# tracks = BioCircosSNPTrack("SNPTrack", 
#                            chromosomes = c(1, 1, 2, 3, 5, 6),
#                            positions = c(12512, 35323441, 434213, 531234, 4213, 5123),
#                            values = c(6, 6, 6, 6, 6, 5),
#                            minRadius = 0.5,
#                            maxRadius = 0.9)



test_data_edit <- test_data %>% 
  filter(Variant.Type == "SNP") %>% 
  select(Chr, Start.Position) %>% 
  mutate(start = floor(Start.Position / 10000000) * 10000000, end = start + (10000000)) %>% 
  group_by(Chr, start, end) %>% 
  summarize(start = start, end = end, count = n()) %>% 
  as.data.frame()
  
  
barTracks = BioCircosBarTrack("myBar", 
                           chromosomes = test_data_edit$Chr,
                           starts = test_data_edit$start,
                           ends = test_data_edit$end,
                           values = test_data_edit$count,
                           minRadius = 0.7,
                           maxRadius = 0.9)

cnvTrack = BioCircosCNVTrack("myCNV",
                             chromosomes = str_replace(cnv_data$Chromosome,
                                                       "chr", ""),
                             starts = cnv_data$Start,
                             ends = cnv_data$End,
                             values = cnv_data$Copy_Number,
                             minRadius = 0.5,
                             maxRadius = 0.6)

sv_data_edit <- sv_data %>% 
  filter(MUTATION_TYPE != "intrachromosomal deletion") %>% 
  select("DESCRIPTION") %>% 
  separate(col = everything(),
           into = c("start", "end"),
           sep = "_") %>% 
  separate(col = start,
           into = c("Chr1", "Start1"),
           sep = ":") %>% 
  separate(col = end,
           into = c("Chr2", "Start2"),
           sep = ":") %>% 
  mutate(Chr1 = sapply(.$Chr1, str_remove, "chr"),
         Chr2 = sapply(.$Chr2, str_remove, "chr"),
         Start1 = sapply(.$Start1, str_remove_all, "[a-z.]+"),
         Start2 = sapply(.$Start2, str_remove_all, "[a-z]+")) %>% 
  drop_na()

svTrack = BioCircosLinkTrack("mySV",
                             gene1Chromosomes = sv_data_edit$Chr1,
                             gene1Starts = as.numeric(sv_data_edit$Start1),
                             gene1Ends = as.numeric(sv_data_edit$Start1) + 1000,
                             gene2Chromosomes = sv_data_edit$Chr2,
                             gene2Starts = as.numeric(sv_data_edit$Start2),
                             gene2Ends = as.numeric(sv_data_edit$Start2) + 1000,
                             maxRadius = 0.4)

tracks = cnvTrack + BioCircosBackgroundTrack("cnvBG",
                                             minRadius = 0.5,
                                             maxRadius = 0.6,
                                             borderColors = "#AAAAAA",
                                             borderSize = 0.5) +
         barTracks + BioCircosBackgroundTrack("barBG",
                                              minRadius = 0.7,
                                              maxRadius = 0.9,
                                              borderColors = "#AAAAAA",
                                              borderSize = 0.6) +
         svTrack + BioCircosBackgroundTrack("svBG",
                                            minRadius = 0,
                                            maxRadius = 0.4,
                                            borderColors = "#AAAAAA",
                                            fillColors = "#EEFFEE",
                                            borderSize = 0)
         

BioCircos(tracks,
          genome = GRCh38.chr.len,
          chrPad = 0.05,
          displayGenomeBorder = F,
          genomeTicksDisplay = F)

















