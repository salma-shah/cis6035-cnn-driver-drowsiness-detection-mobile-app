class FrameProcessor {
  int frameCount = 0;
  bool isProcessing = false;

  // only running inference every 5 frames
  bool runCNNInference(){
    frameCount++;

    if (frameCount % 30 == 0 )
    {
      return true;
    }
    return false;
  }

  bool runMediaPipeInference(){
    frameCount ++;
    if (frameCount % 30 == 0)
    {
      return true;
    }
    return false;
  }
  void reset() {
    frameCount = 0;
  }
}
