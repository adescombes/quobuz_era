#!/bin/bash

# Usage check
if [ $# -ne 1 ]; then
  echo "Usage: $0 fichier.csv"
  exit 1
fi

INPUT="$1"
BASENAME=$(basename "$INPUT" .csv)
LINES_PER_FILE=199
OUTDIR="chunks"

# Vérifications
if [ ! -f "$INPUT" ]; then
  echo "❌ Fichier introuvable : $INPUT"
  exit 1
fi

# Header
header=$(head -n 1 "$INPUT")

# Préparer le dossier de sortie
mkdir -p "$OUTDIR"
rm -f "$OUTDIR/${BASENAME}_*.csv"

# Découpage sans le header
tail -n +2 "$INPUT" | split -l $LINES_PER_FILE - "$OUTDIR/temp_"

# Reconstruction avec header + numérotation
i=1
for file in "$OUTDIR"/temp_*; do
  printf "%s\n" "$header" > "$OUTDIR/${BASENAME}_$(printf "%03d" $i).csv"
  cat "$file" >> "$OUTDIR/${BASENAME}_$(printf "%03d" $i).csv"
  rm "$file"
  ((i++))
done

echo "✅ $((i-1)) fichiers créés dans le dossier '$OUTDIR/'"
