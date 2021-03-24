var audio;

document.querySelectorAll(".meme").forEach((meme) => {
  const playBtn = meme.querySelector(".play");
  const stopBtn = meme.querySelector(".stop");
  const progressBar = meme.querySelector(".progress-bar");

  const onTimeUpdate = (event) => {
    const { currentTime, duration } = event.target;
    const progress = (currentTime + 0.25) / duration;
    progressBar.style.width = `${progress * 100}%`;
  };

  const onPlay = (event) => {
    playBtn.style.display = "none";
    stopBtn.style.display = "block";
    onTimeUpdate(event);
  };

  const onStop = (event) => {
    playBtn.style.display = "block";
    stopBtn.style.display = "none";
    progressBar.style.transition = "none";
    progressBar.style.width = "0";
    setTimeout(() => {
      progressBar.style.transition = "";
    }, 0);
  };

  const play = () => {
    audio = new Audio(meme.dataset.audio);
    audio.addEventListener("play", onPlay);
    audio.addEventListener("pause", onStop);
    audio.addEventListener("timeupdate", onTimeUpdate);
    audio.addEventListener("ended", onStop);
    audio.play();
  };

  const stop = () => {
    audio.pause();
  };

  playBtn.addEventListener("click", play);
  stopBtn.addEventListener("click", stop);
});
