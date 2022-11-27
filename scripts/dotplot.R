if (!require("pacman", quietly = TRUE)) {
    install.packages("pacman")
}
pacman::p_load(tidyverse, fs, readxl, ggrepel)
dir_create(c("data", "reports"))

file <- str_glue("{getwd()}/data/mmc2.xlsx")
if (!file_exists(file)) {
    url <- "https://www.cell.com/cms/10.1016/j.cell.2016.12.016/attachment/c0d900bf-e751-437b-b0aa-0388e93e5a03/mmc2.xlsx"
    download.file(url, file)
}

df_table <- read_excel(file, skip = 3)
df_genes <- read_csv("data/target_genes.csv", col_names = "name")

df <- df_table %>%
    select("name", "MEFs", "ESCs") %>%
    inner_join(df_genes, by = "name")

df_plot <-
    df %>%
    mutate(div = (ESCs + 1) / (MEFs + 1)) %>%
    mutate(log2FC = log(div, base = 2)) %>%
    arrange(desc(log2FC)) %>%
    mutate(name = fct_inorder(name))

threshold <- 1
targets <- c("Bclaf1", "Fubp1", "Msh6", "Park7", "Psip1", "Thrap3")

pos <- position_jitter(width = 0.5, seed = 0)

g_dot <-
    df_plot %>%
    mutate(color = if_else(log2FC > threshold, "#df7163", "gray80")) %>%
    mutate(label = if_else(
        str_detect(name, str_c(targets, collapse = "|")), name, as.factor(NA)
    )) %>%
    ggplot(aes(x = NA, y = log2FC, label = label)) +
    geom_hline(yintercept = threshold, linetype = "dashed", color = "#333333") +
    geom_violin(aes(color = "gray75")) +
    geom_jitter(aes(color = color), position = pos) +
    geom_label_repel(
        size = 6,
        position = pos,
        min.segment.length = 0,
        max.overlaps = Inf,
        box.padding = 1,
        fill = "white",
        segment.size = 1,
        show.legend = FALSE
    ) +
    scale_colour_identity() +
    labs(x = NULL, y = "log2-FC") +
    theme_bw() +
    theme(
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank()
    )

ggsave("reports/dotplot_log2fc.png", g_dot, dpi = 600)
ggsave("reports/dotplot_log2fc.pdf", g_dot)

df_plot %>%
    mutate(threshold = if_else(log2FC > threshold, TRUE, FALSE)) %>%
    arrange(desc(log2FC)) %>%
    select(name, MEFs, ESCs, log2FC, threshold) %>%
    write_csv("reports/expression_log2fc.csv")
