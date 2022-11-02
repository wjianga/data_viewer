library(tidyverse)

setwd("/stor/work/FRI-BigDataBio/wj3972/data_viewer/data")

# hg18
# https://genome.ucsc.edu/goldenPath/stats.html#hg18
GRCh36.chr.len <- c(247249719, 242951149, 199501827, 191273063,
                    180857866, 170899992, 158821424, 146274826, 140273252,
                    135374737, 134452384, 132349534, 114142980, 106368585,
                    100338915, 88827254, 78774742, 76117153, 63811651,
                    62435964, 46944323, 49691432, 154913754, 57772954)

# hg19
# https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg19&chromInfoPage=
GRCh37.chr.len <- c(249250621, 243199373, 198022430, 191154276,
                    180915260, 171115067, 159138663, 146364022, 141213431,
                    135534747, 135006516, 133851895, 115169878, 107349540,
                    102531392, 90354753, 81195210, 78077248, 59128983,
                    63025520, 48129895, 51304566, 155270560, 59373566)

# hg38
# https://genome.ucsc.edu/cgi-bin/hgTracks?db=hg38&chromInfoPage=
GRCh38.chr.len <- c(248956422, 242193529, 198295559, 190214555,
                    181538259, 170805979, 159345973, 145138636, 138394717,
                    133797422, 135086622, 133275309, 114364328, 107043718,
                    101991189, 90338345, 83257441, 80373285, 58617616,
                    64444167, 46709983, 50818468, 156040895, 57227415)

GRCh36.chr.pos <- cumsum(GRCh36.chr.len)

GRCh37.chr.pos <- cumsum(GRCh37.chr.len)

GRCh38.chr.pos <- cumsum(GRCh38.chr.len)

output <- data.frame(chrom = paste("chr", c(1:22, "X", "Y"), sep = ""),
                     # chromStart = c(0, GRCh36.chr.pos[-24]),
                     chromStart = 0,
                     chromEnd = GRCh36.chr.pos,
                     optional1 = 0,
                     optional2 = 0)

write.csv(output, file = "GRCh36_hg18.csv", row.names = F)



output <- data.frame(chrom = paste("chr", c(1:22, "X", "Y"), sep = ""),
                     # chromStart = c(0, GRCh37.chr.pos[-24]),
                     chromStart = 0,
                     chromEnd = GRCh37.chr.pos,
                     optional1 = 0,
                     optional2 = 0)

write.csv(output, file = "GRCh37_hg19.csv", row.names = F)



output <- data.frame(chrom = paste("chr", c(1:22, "X", "Y"), sep = ""),
                     # chromStart = c(0, GRCh38.chr.pos[-24]),
                     chromStart = 0,
                     chromEnd = GRCh38.chr.len,
                     optional1 = 0,
                     optional2 = 0)

write.csv(output, file = "GRCh38_hg38.csv", row.names = F)
