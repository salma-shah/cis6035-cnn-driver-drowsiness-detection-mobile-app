class FrameProcessor {
  int frameCount = 0;
  bool isProcessing = false;

  // only running inference every 30 frames
  bool runCNNInference(){
    frameCount++;

    if (frameCount % 30 == 0 )
    {
      return true;
    }
    return false;
  }

  // media pipe is not as computationally expensive as CNN so inference will be run om
  // every 15 frames
  bool runMediaPipeInference(){
    frameCount ++;
    if (frameCount % 15 == 0)
    {
      return true;
    }
    return false;
  }
  void reset() {
    frameCount = 0;
  }
}
