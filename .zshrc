# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
setopt appendhistory autocd
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/shiv/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

prompt walters

source /usr/share/doc/pkgfile/command-not-found.zsh
autoload -U promptinit

autoload zkbd
source ~/.zkbd/$TERM-:0 # may be different - check where zkbd saved the configuration:

[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char

streaming() {
     INRES="1920x1080" # input resolution
     OUTRES="640x480" # output resolution
     FPS="30" # target FPS
     GOP="60" # i-frame interval, should be double of FPS, 
     GOPMIN="30" # min i-frame interval, should be equal to fps, 
     THREADS="2" # max 6
     CBR="1000k" # constant bitrate (should be between 1000k - 3000k)
     QUALITY="ultrafast"  # one of the many FFMPEG preset
     AUDIO_RATE="44100"
     STREAM_KEY="$1" # use the terminal command Streaming streamkeyhere to stream your video to twitch or justin
     SERVER="live" # twitch server in frankfurt, see http://bashtech.net/twitch/ingest.php for list
     
     ffmpeg -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE \
       -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p\
       -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal \
       -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
 }
