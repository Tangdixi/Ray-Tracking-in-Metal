import MetalKit

public class Canvas: NSObject {
    
    public lazy var device: MTLDevice = makeDevice()
    lazy var queue: MTLCommandQueue = makeCommandQueue()
    lazy var computePipelineState: MTLComputePipelineState = makeComputePipelineState()
    
    init(_ metalView: MTKView) {
        super.init()
        
        metalView.delegate = self
        metalView.device = device
        metalView.framebufferOnly = false
    }
    
}

extension Canvas: MTKViewDelegate {
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        else { fatalError() }
        
        // Configuration
        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        
        // Optimize
        let width = computePipelineState.threadExecutionWidth
        let height = computePipelineState.maxTotalThreadsPerThreadgroup/width
        let threadsPerThreadGroup = MTLSize(width: width, height: height, depth: 1)
        let threadGroupPerGrid = MTLSize(width: (drawable.texture.width+width-1)/width,
                                         height: (drawable.texture.height+height-1)/height, depth: 1)

        commandEncoder.dispatchThreadgroups(threadGroupPerGrid,
                                            threadsPerThreadgroup: threadsPerThreadGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Canvas {
    func makeDevice() -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported in this device")
        }
        return device
    }
    func makeCommandQueue() -> MTLCommandQueue {
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError()
        }
        return commandQueue
    }
    func makeComputePipelineState() -> MTLComputePipelineState {
        
        guard let library = device.makeDefaultLibrary(),
            let kernel = library.makeFunction(name: "compute"),
            let computePipelineState = try? device.makeComputePipelineState(function: kernel) else {
                fatalError()
        }
        
        return computePipelineState
    }
}

